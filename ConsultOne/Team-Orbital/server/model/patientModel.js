const mongoose=require("mongoose")

const patientschema=new mongoose.Schema({
    name:{
        type:String,
        required:true,
    },
    email:{
        type:String,
        required:true,
    },
    password:{
        type:String,
        required:true,
    },
    phoneNo:{
        type:String,
        required:true,
    },
    fcmToken: {
        type: String,
        default: null
    },
    role: {
        type: String,
        default: "patient"
    },
    balance:{
        type:Number,
        default:0
    }

},{timestamps:true})

const Patient=new mongoose.model("patient",patientschema);
module.exports=Patient;