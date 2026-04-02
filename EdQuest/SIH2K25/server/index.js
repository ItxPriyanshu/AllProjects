const express = require("express");
const mongoose = require("mongoose");
const authRouter = require("./routes/auth");
const dotenv = require("dotenv");
const cors = require("cors");
const PORT = process.env.PORT || 5000;
const app = express();
require('dotenv').config();
app.use(cors());


mongoose
.connect(process.env.MONGODB_URI)

.then (()=> {console.log("Connected to MongoDB");})
.catch ((err)=> {console.error("Error connecting to MongoDB:", err);});
app.use(express.json());
app.use("/api",authRouter);
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Server is running on port ${PORT}`);
});