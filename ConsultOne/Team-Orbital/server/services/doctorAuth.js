const JWT_DOCTOR_PASSWORD = "$oneTime"
const jwt = require("jsonwebtoken");

function createToken(doctor){

    const token = jwt.sign({
            id : doctor._id  
        }, JWT_DOCTOR_PASSWORD)

        return token

}

function validateToken(token){
    const decodedPassword = jwt.verify(token, JWT_DOCTOR_PASSWORD)
    return decodedPassword
}

module.exports = ({
    createToken,
    validateToken
})