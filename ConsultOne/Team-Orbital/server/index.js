require("dotenv").config()
require("./configuration/firebase.js") // Initialize Firebase Admin
const express = require("express")
const app = express()
const handlehome = require("./routes/home.js")
const adminRoutes = require("./routes/admin.js")
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const handlePatientRoute = require("./routes/patient.js")
const { doctorRouter } = require("./routes/doctor.js")
const newsRoute = require("./routes/news.js");
const handlePayment = require("./routes/payment.js")
const port = process.env.PORT || 5000;
const mongoose = require("mongoose")
const path = require("path");
const cors = require("cors")
app.set("view engine", "ejs");
app.set("views", path.resolve("./views"))


//database connected-------->
mongoose.connect("mongodb+srv://orbital:orbital1058@cluster0.ediaafr.mongodb.net/Consultone").then(() => {
    console.log("database connect ho gya")
})

// route for the patient ---->
app.use("/patient", handlePatientRoute);
app.use("/doctor", doctorRouter);
app.use("/home", handlehome);
app.use("/news", newsRoute);
app.use("/payment", handlePayment);
app.use("/admin", adminRoutes);
app.listen(port, () => {
    console.log("server started");
})
