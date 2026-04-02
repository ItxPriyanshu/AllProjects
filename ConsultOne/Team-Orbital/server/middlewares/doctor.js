const jwt = require("jsonwebtoken")
const JWT_DOCTOR_PASSWORD = "$oneTime"
const {validateToken} = require("../services/doctorAuth")



function doctorMiddleware(req,res,next){
    try {
        const token = req.headers.authorization?.split(" ")[1];
        
        if (!token) {
            console.log('Doctor middleware: No token provided');
            return res.status(403).json({
                error: "You are not signed in"
            });
        }
        
        const decodedPassword = validateToken(token);
        
        if(!decodedPassword || !decodedPassword.id){
            console.log('Doctor middleware: Invalid token or missing id');
            return res.status(403).json({
                error: "You are not signed in"
            });
        }
        
        req.doctorId = decodedPassword.id;
        console.log('Doctor middleware: Authenticated doctor ID:', req.doctorId);
        next();
    } catch (error) {
        console.error('Doctor middleware error:', error);
        return res.status(403).json({
            error: "Invalid or expired token"
        });
    }
}

module.exports = {
    doctorMiddleware : doctorMiddleware
}