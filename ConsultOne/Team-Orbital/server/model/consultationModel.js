const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const consultSchema = new mongoose.Schema(
  {
    full_name: {
      type: String,
      required: true,
    },

    age: {
      type: String,
      required: true,
    },

    gender: {
      type: String,
      required: true,
    },

    contactNo: {
      type: String,
      required: true,
    },

    Problem: {
      type: String,
    },

    life_style: {
      type: String,
    },

    // patient reference
    patient_id: {
      type: Schema.Types.ObjectId,
      ref: "patient",
    },

    // patient uploaded file (stored on Cloudinary)
    patientFileUrl: {
      type: String,
    },

    // doctor reference
    doctor_id: {
      type: Schema.Types.ObjectId,
      ref: "doctors",
    },

    // doctor uploaded prescription file
    doctorFileUrl: {
      type: String,
    },

    // doctor text prescription / response
    doctorTextResponse: {
      type: String,
    },

    // consultation type
    type: {
      type: String,
      enum: ["normal", "emergency"],
    },

    // consultation status
    status: {
      type: String,
      enum: ["pending", "responded"],
      default: "pending",
    },
  },
  {
    timestamps: true,
  }
);

const Consultation = mongoose.model("consultation", consultSchema);

module.exports = Consultation;
