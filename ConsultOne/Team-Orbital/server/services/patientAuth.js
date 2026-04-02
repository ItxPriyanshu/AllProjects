const JWT=require("jsonwebtoken")
const secret="optimusprime";
//creating token for patient----------->
function createPatientToken(patient){
    const payload={
        id:patient._id,
        email:patient.email,
        role:patient.role,
    };
    const token =JWT.sign(payload,secret);
    return token;

}
//token validity checking ---------->
function validPatientToken(token){
    return JWT.verify(token,secret);
    
}
// middleware for token checking -------->
function checkValidPatient(req, res, next) {
  const token = req.headers.authorization?.split(" ")[1];
  try {
    const patientPayload = validPatientToken(token);
    req.patient = patientPayload;
    next();
  } catch (error) {
    return res.status(401).json({
      message: "Invalid or expired token",
    });
  }
}
module.exports={
    createPatientToken,validPatientToken,checkValidPatient,
}