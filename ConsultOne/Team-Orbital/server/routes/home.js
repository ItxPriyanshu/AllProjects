const express=require("express")
const router = express.Router();
const {DoctorModel}=require("../model/doctorModel.js")
const Patient=require("../model/patientModel.js");
const {checkValidPatient}=require("../services/patientAuth.js")
const {ai} =require("../configuration/gemini.js");
const Notification=require("../model/notificationModel.js")
// pacakage require for the report analyzer----->
const multer=require("multer")
const storage = multer.memoryStorage();// ye RAM me store karta hai file ke binary form ko 
const upload = multer({
    storage,
    limits: { fileSize: 10 * 1024 * 1024 } // max size 10MB ho sakta hai 
});

// route for the google gemini chatbot -------->
router.route("/gemini").post(async(req,res)=>{
    try{
        const { prompt } = req.body;

         if (!prompt) {// agar prompt hi nhi diya 
      return res.status(400).json({
        error: "Prompt is required",
      });
    }
    // instruction to  customize --------->
const Health_bot_instruct=`You are a professional medical assistant AI.
You ONLY answer health and medical related questions.
If the user asks anything unrelated to health, politely refuse.
Do not prescribe medication.
Do not provide final diagnosis.
Always encourage consulting a doctor.
Always add disclaimer: "This does not replace professional medical advice.Give answer in 10 line max"`

    // responce ------------>
    const response = await ai.models.generateContent({
      model: "gemini-2.5-flash",
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
      config: {
        systemInstruction: Health_bot_instruct,
        temperature: 0.4,
      },
    });

    res.json({
      reply: response.text,
    });


    }
    catch(err){
        return res.status(500).json({error:`unable to answer right now1${err}`});
    }

})

//route to tell how many doctors and patients have login yet--------->
router.route("/").get(checkValidPatient, async (req, res) => {
    try {
        const totalPatient = await Patient.estimatedDocumentCount();
        const totalDoctor = await DoctorModel.estimatedDocumentCount();

        // get latest notification
        const latest = await Notification
            .findOne()
            .sort({ createdAt: -1 })
            .lean();

        return res.json({ totalPatient, totalDoctor, latest });

    } catch (error) {
        console.error(error);
        res.status(500).json({ error: "Server error" });
    }
});
// route to analyze the report ------->
router.route("/analyze-Report").post(upload.single("report"),async(req,res)=>{
  if (req.file) {
    const base64Image = req.file.buffer.toString("base64");
    const customMessage=`You are a professional medical report analysis assistant AI.

Your task is to strictly extract and organize ONLY the clinical and medical data from the uploaded report.

IMPORTANT RULES:
- Do NOT prescribe medication.
- Do NOT give diagnosis.
- Do NOT add your own medical knowledge.
- Do NOT explain medical concepts.
- Only rewrite and organize what is written in the report.
- Extract ONLY medical and clinical findings.
- DO NOT include:
  • Hospital name
  • Hospital address
  • Hospital contact details
  • Billing details
  • Invoice numbers
  • Payment information
  • Patient home address
  • Administrative details
  • Registration numbers
- If any value is unclear, write: "Not clearly readable in report".
- Do NOT return JSON.
- Return ONLY clean formatted text.
- At the end, add a separate SUMMARY section written in simple language.
- The summary must NOT include patient personal information (name, age, address).
- The summary must NOT include hospital or billing information.
- Do not add extra interpretation beyond what is written.
-Add patient name  in the starting only if it is given.

OUTPUT FORMAT RULES:

- Create clear section headings based ONLY on medical categories present in the report (e.g., Blood Pressure, Blood Sugar, Hemoglobin, MRI, X-Ray, CBC, Iron, Thyroid, etc.).
- Headings must be in UPPERCASE.
-Add numbering or bullet points for the heading .
- Headings must appear visually bold, but DO NOT use asterisks (**).
- Leave one blank line before and after each heading.
- Under each heading, list only the exact medical values or statements written in the report.
- Do NOT add explanation.
- Do NOT add non-medical information.

At the end, add:

SUMMARY

(Write simple summary here – only medical findings, no personal or hospital details.)

On a new line after summary, add:

"This is the information I extracted from your report."`
   const response = await ai.models.generateContent({
  model: "gemini-2.5-flash",
  contents: [
    {
      role: "user",
      parts: [
        {
          inlineData: {
            mimeType: req.file.mimetype,
            data: base64Image,
          },
        },
        {
          text: "Extract important medical data from this report."
        }
      ],
    },
  ],
  config: {
    systemInstruction:customMessage ,
    temperature: 0.2,
  },
});
   return res.json({result:response.text})
       
    }

})
module.exports=router;