const express = require("express");
const  router = express.Router();
const crypto = require("crypto");

const Patient = require("../model/patientModel.js");
const { razorpay } = require("../configuration/razorpay.js");

////////////////////////////////////////////////////////////
// route for order create
////////////////////////////////////////////////////////////

router.route("/").post(async (req,res)=>{
   try {

    const { fees } = req.body;

    const order = await razorpay.orders.create({
      amount: fees * 100,
      currency: "INR",
      receipt: "receipt_" + Date.now(),
    });

    return res.status(200).json({
      success:true,
      order,
      key_id: process.env.RAZORPAY_KEY_ID
    });

   }
   catch(error){
     res.status(500).json({ error: error.message });
   }

});

////////////////////////////////////////////////////////////
// route for payment verification
// 👉 if patientId present → add money to balance
// 👉 else → normal verify
////////////////////////////////////////////////////////////

router.route("/verify").post(async (req,res)=>{

  const { rzO_ID, rzP_ID, rzSign, patientId, amount } = req.body;

  const body = rzO_ID + "|" + rzP_ID;

  const expectedSignature = crypto
      .createHmac("sha256", process.env.RAZORPAY_KEY_SECRET)
      .update(body)
      .digest("hex");

  if (expectedSignature === rzSign) {

      // 🔥 If patientId provided → add money to wallet
      if(patientId){

          const patient = await Patient.findById(patientId);

          if(!patient){
              return res.status(404).json({ message: "Patient not found" });
          }

          patient.balance += amount;
          await patient.save();

          return res.json({
            success: true,
            message: "Payment verified & wallet credited",
            balance: patient.balance
          });
      }

      // 🔥 If no patientId → old behaviour
      return res.json({
        success: true,
        message: "Payment verified"
      });

  }
  else {
      return res.status(400).json({
        success: false,
        message: "Payment failed"
      });
  }

});

////////////////////////////////////////////////////////////
// route for pay using wallet
////////////////////////////////////////////////////////////

router.route("/pay-with-wallet").post(async (req,res)=>{

    const { patientId, fee } = req.body;

    const patient = await Patient.findById(patientId);

    if(!patient){
        return res.status(404).json({ message: "Patient not found" });
    }

    if(patient.balance < fee){
        return res.json({
            success:false,
            message:"Insufficient wallet balance"
        });
    }

    // 🔥 deduct money
    patient.balance -= fee;
    await patient.save();

    return res.json({
        success:true,
        message:"Payment done using wallet",
        balance: patient.balance
    });

});

module.exports = router;