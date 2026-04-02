
const express = require("express");
const router = express.Router();

const { DoctorModel } = require("../model/doctorModel");
const Patient = require("../model/patientModel");
const patientIssue=require("../model/patientIssueModel");
const Notification=require("../model/notificationModel.js")
router.route("/").get(async(req,res)=>{
    const totalDoctors = await DoctorModel.countDocuments();
  const totalPatients = await Patient.countDocuments();
  const totalIssues = await patientIssue.countDocuments();
  const totalUnverifiedDoctors = await DoctorModel.countDocuments({ isVerified: false });
    res.render("adminHome",{
        totalDoctors,
        totalPatients,
        totalIssues,
        totalUnverifiedDoctors
    });
})
router.route("/doctors").get(async(req,res)=>{
    const doctors = await DoctorModel.find();
    res.render("adminDoctor",{doctors});
})
router.route("/patients").get(async(req,res)=>{
    const patients = await Patient.find();
    res.render("adminPatient",{patients});
})
router.route("/patients/delete/:id").post(async(req,res)=>{
    await Patient.findByIdAndDelete(req.params.id);
    res.redirect("/admin/patients")
})
router.route("/doctors/delete/:id").post(async(req,res)=>{
    await DoctorModel.findByIdAndDelete(req.params.id);
    res.redirect("/admin/doctors")
})
router.route("/issues").get(async(req,res)=>{
   const issues =await patientIssue.find().sort({ createdAt: -1 });
   res.render("adminPatientIssue",{
    pageTitle: "Patient Issues - Admin",
      heading: "All Patient Issues",
      issues: issues,
   });
})
//route to verify the doctor ----->
router.route("/verification/:id").post(async(req,res)=>{
     await DoctorModel.findByIdAndUpdate(
            req.params.id,
            { isVerified: true },
            { new: true }
        );
        res.redirect("/admin/doctors/unverified");
})
// route to verify ---->
router.get("/doctors/unverified", async (req, res) => {
  try {
    const doctors = await DoctorModel.find({ isVerified: false }).lean();

    res.render("unverifiedDoctors", {
      doctors
    });

  } catch (error) {
    res.send("Error fetching unverified doctors");
  }
});
// router to set the imp notification ---->
router.post("/notification", async (req, res) => {

    try {

        const message = req.body.message;

        await Notification.create({
            message: message
        });

        // ✅ redirect to admin dashboard
        res.redirect("/admin");

    } catch (error) {

        console.log(error);

        res.status(500).send("Error saving notification");

    }

});

// open notification page
router.get("/notification", async (req, res) => {

    res.render("adminNotification");

});



module.exports=router;