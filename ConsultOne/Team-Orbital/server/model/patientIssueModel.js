
const mongoose=require("mongoose")

const PatientIssue=new mongoose.Schema({
    name:{
        type:String,
        required:true,
    },
    registrationID:{
        type:String,
        required:true,
    },
    problem:{
        type:String,
        required:true,
    }
},{timestamps:true});

const patientIssue=new mongoose.model("patientIssue",PatientIssue);
module.exports=patientIssue;