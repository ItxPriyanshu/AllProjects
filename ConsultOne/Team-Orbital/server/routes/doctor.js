const { Router } = require("express");
const doctorRouter = Router();
const { DoctorModel } = require("../model/doctorModel");
const bcrypt = require('bcrypt');
const { z } = require("zod");
const { doctorMiddleware } = require("../middlewares/doctor");
const { createToken } = require("../services/doctorAuth")
const Consultation = require("../model/consultationModel")
const cloudinary = require("../configuration/cloudinary.js")
const { generateMaskedNumber } = require("../configuration/exotel.js");
const streamifier = require("streamifier");// for clodinary
const multer = require("multer");
///////////
const storage = multer.memoryStorage();

const upload = multer({
    storage, limits: { fileSize: 10 * 1024 * 1024 } // 10MB
});

//
const uploadToCloudinary = (buffer, folder) => {
    return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
            { folder },
            (error, result) => {
                if (result) resolve(result);
                else reject(error);
            }
        );

        streamifier.createReadStream(buffer).pipe(stream);
    });
};
// this is route for showing form 

doctorRouter.get("/showform/:consultId", doctorMiddleware, async function (req, res) {
    try {
        const consultId = req.params.consultId;

        const consultation = await Consultation.findById(consultId)
            .populate("patient_id", "name")
            .populate("doctor_id", "name speciality");


        if (!consultation) {
            return res.status(404).json({ msg: "Consultation not found" });
        }

        res.json(consultation);

    } catch (e) {
        res.status(500).json({ msg: "Server error", error: e.message });
    }
});
// route for the doctor to upload the file ------------>
doctorRouter
.route("/form/:consultId")
.post(
    doctorMiddleware,
    upload.single("doctorAnswer"),
    async (req, res) => {

        try {

            const _id = req.params.consultId;
            const doctorId = req.doctorId;

            // get text response
            const textResponse = req.body.textResponse;

            let doctorFileUrl;

            if (req.file) {

                const cloudResult = await uploadToCloudinary(
                    req.file.buffer,
                    "doctor_uploads"
                );

                doctorFileUrl = cloudResult.secure_url;
            }

            const response = await Consultation.findByIdAndUpdate(
                {
                    _id,
                    doctor_id: doctorId
                },
                {
                    status: "responded",

                    doctorFileUrl: doctorFileUrl,

                    doctorTextResponse: textResponse
                },
                {
                    new: true
                }
            );

            return res.status(200).json({
                message: "Response submitted successfully",
                response
            });

        } catch (error) {

            console.log(error);

            return res.status(500).json({
                message: "Server error"
            });
        }

    }
);



// signup route for doctor
doctorRouter.post("/signup", async function (req, res) {
    const requireBody = z.object({
        email: z
            .string()
            .min(3, "Email must be at least 3 characters")
            .max(100, "Email too long")
            .email("Invalid email format"),

        password: z
            .string()
            .min(8, "Password must be at least 8 characters long")
            .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
            .regex(/[0-9]/, "Password must contain at least one number")
            .regex(/[^A-Za-z0-9]/, "Password must contain at least one special character"),

        name: z
            .string()
            .min(3, "Name must be at least 3 characters")
            .max(100, "Name too long")
            .regex(/^[A-Za-z ]+$/, "Name can only contain letters and spaces"),

        phone: z
            .string()
            .regex(/^[6-9]\d{9}$/, "Invalid Indian phone number (must be 10 digits starting 6–9)"),

        licenceId: z
            .string()
            .min(5, "Licence ID should be at least 5 characters")
            .max(50, "Licence ID too long"),

        availTime: z
            .string()
            .min(3, "Availability time is required")
            .max(50, "Too long for time field"),

        fees: z
            .number()
            .nonnegative("Fees must be 0 or a positive number"),

        speciality: z
            .string()
    });

    const parsedDataWithSuccess = requireBody.safeParse(req.body)

    if (!parsedDataWithSuccess.success) {
        res.json({
            msg: "Incorrect Format",
            error: parsedDataWithSuccess.error
        })
        return
    }
    const { email, password, name, phone, licenceId, availTime, fees, speciality,experience } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 5);

        await DoctorModel.create({
            email, 
        password: hashedPassword, 
        name, 
        phone, 
        licenceId, 
        availTime, 
        fees, 
        speciality,
        experience

        });

    } catch (e) {

        if (e.code === 11000) {
            if (e.keyPattern?.email) {
                return res.status(400).json({ msg: "Email already in use" });
            }
            if (e.keyPattern?.licenceId) {
                return res.status(400).json({ msg: "Licence ID already registered" });
            }
        }

        if (e.name === "ValidationError") {
            return res.status(400).json({
                msg: "Schema validation failed",
                error: e.message
            });
        }

        console.log("Signup error:", e);
        return res.status(500).json({ msg: "Internal server error" });
    }

    return res.status(201).json({
        msg: "You are signed up successfully"
    });

})


// signin route for doctor

doctorRouter.post("/signin", async function (req, res) {

    const { email, password } = req.body
    const doctor = await DoctorModel.findOne({
        email: email
    })

    if (!doctor) {
        return res.status(404).json({
            msg: "Doctor does not exist in our db"
        })
    }

    const passwordMatched = await bcrypt.compare(password, doctor.password)

    if (passwordMatched) {
        // Only allow login if doctor is verified
        if (!doctor.isVerified) {
            return res.status(403).json({
                msg: "Doctor account is not verified. Please wait for verification."
            });
        }

        const token = createToken(doctor)

        return res.json({
            token: token,
            doctorName: doctor.name
        })
    } else {
        return res.status(401).json({
            msg: "Incorrect Credentials"
        })
    }


})

// this is route for showing unsolved normal cases

doctorRouter.get("/cases/normal", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;

        const cases = await Consultation.find({
            doctor_id: doctorId,
            type: "normal",
            status: "pending"
        })
            .sort({ createdAt: -1 });

        res.json(cases);
    }
    catch (e) {
        res.status(500).json({ msg: "Server error", error: e.message });
    }
});

// this is route for showing unsolved emergency cases

doctorRouter.get("/cases/emergency", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;

        const cases = await Consultation.find({
            doctor_id: doctorId,
            type: "emergency",
            status: "pending"
        })
            .sort({ createdAt: -1 });

        res.json(cases);
    }
    catch (e) {
        res.status(500).json({ msg: "Server error", error: e.message });
    }
});


// route for implementing masked phone number

doctorRouter.get("/emergency/masked/:consultId", doctorMiddleware, async function (req, res) {
    try {
        const consultId = req.params.consultId;
        const doctorId = req.doctorId;

        // Find case only by consultation ID (since it's unique)
        const consultation = await Consultation.findById(consultId)
            .populate("patient_id", "phoneNo");

        if (!consultation) {
            return res.json({
                error: "Consultation not found"
            });
        }

        // Ensure it is an emergency case
        if (consultation.type !== "emergency") {
            return res.json({
                error: "This is not an emergency case"
            });
        }

        // Ensure doctor is authorized
        if (consultation.doctor_id.toString() !== doctorId) {
            return res.status(403).json({
                error: "You are not authorized to access this case"
            });
        }

        // Get patient phone number
        const patientPhone = consultation.patient_id?.phoneNo;
        const doctorPhone = req.doctorPhone; // From middleware (if available)

        // Generate masked number using Exotel
        const result = await generateMaskedNumber(
            patientPhone || "08045889186",
            doctorPhone,
            process.env.EXOTEL_VIRTUAL_NUMBER || '08045889186'
        );

        res.json({
            maskedNumber: result.maskedNumber,
            sessionId: result.sessionId,
            msg: "Use this masked number to call the patient. Your privacy is protected."
        });
    } catch (error) {
        console.error('Error in emergency masked route:', error);
        res.status(500).json({
            error: "Failed to generate masked number",
            maskedNumber: "08045889186" // Fallback
        });
    }
});

// this is route for showing history of attended cases by doctor

doctorRouter.get("/history", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;

        const cases = await Consultation.find({
            doctor_id: doctorId,
            status: "responded"
        })
            .sort({ createdAt: -1 });

        res.json(cases);
    }
    catch (e) {
        res.status(500).json({ msg: "Server error", error: e.message });
    }
});


// route to get doctor profile (excluding password and fcmToken)
doctorRouter.get("/profile", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;

        const doctor = await DoctorModel.findById(doctorId)
            .select("-password -fcmToken");

        if (!doctor) {
            return res.status(404).json({
                msg: "Doctor not found"
            });
        }

        return res.status(200).json({
            doctor
        });

    } catch (e) {
        return res.status(500).json({
            msg: "Server error",
            error: e.message
        });
    }
});

// route of editing profile 

doctorRouter.post("/edit", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;

        const { name, phone, availTime, fees, speciality } = req.body;


        // Build update object dynamically (only include provided fields)
        const updateData = {};

        if (name !== undefined) updateData.name = name;
        if (phone !== undefined) updateData.phone = phone;
        if (availTime !== undefined) updateData.availTime = availTime;
        if (fees !== undefined) updateData.fees = fees;
        if (speciality !== undefined) updateData.speciality = speciality;

        const updatedDoctor = await DoctorModel.findByIdAndUpdate(
            doctorId,
            { $set: updateData },
            { new: true }
        ).select("-password -fcmToken");

        if (!updatedDoctor) {
            return res.status(404).json({
                msg: "Doctor not found"
            });
        }

        return res.status(200).json({
            msg: "Doctor details updated successfully",
            doctor: updatedDoctor
        });

    } catch (e) {
        console.error(e);
        return res.status(500).json({
            msg: "Internal server error",
            error: e.message
        });
    }
});


// route to save FCM token for video calls
doctorRouter.post("/fcm", doctorMiddleware, async function (req, res) {
    try {
        const doctorId = req.doctorId;
        const { fcmToken } = req.body;

        if (!fcmToken) {
            return res.status(400).json({ error: "fcmToken is required" });
        }

        const updatedDoctor = await DoctorModel.findByIdAndUpdate(
            doctorId,
            { fcmToken: fcmToken },
            { new: true }
        ).select("-password");

        if (!updatedDoctor) {
            return res.status(404).json({ error: "Doctor not found" });
        }

        return res.status(200).json({
            success: true,
            msg: "FCM Token registered successfully",
        });

    } catch (error) {
        console.error("Error saving FCM token:", error);
        return res.status(500).json({ error: "Failed to register device token" });
    }
});


module.exports = {
    doctorRouter: doctorRouter
}