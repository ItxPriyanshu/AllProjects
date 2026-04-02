const mongoose = require("mongoose")
const Schema = mongoose.Schema;   

const DoctorSchema = new Schema({
    email : { type: String, unique: true, required: true },
    password : { type: String, required: true },
    name : { type: String, required: true },
    phone : { type: String, required: true},
    licenceId : { type: String, required: true, unique: true },
    availTime : { type: String, required: true },
    fees : { type: Number, required: true },
    speciality : { type : String, required : true },

    // CHANGED TO STRING
    experience : { type: String, required: true },

    fcmToken : { type: String, default: null },
    role : { type : String, default : "doctor"},
    isVerified: {
        type: Boolean,
        default: false,   
    }

},{timestamps:true});

const DoctorModel = mongoose.model('doctors', DoctorSchema)

module.exports = {
    DoctorModel
}