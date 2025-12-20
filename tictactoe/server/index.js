const express = require('express');
const http = require('http');
const Mongoose = require('mongoose');
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const Room = require('./models/rooms')
var io = require('socket.io')(server);


//middleware
app.use(express.json());

const DB = "mongodb+srv://priyanshu:priyanshu123@cluster0.ku6ojhd.mongodb.net/?appName=Cluster0";

io.on("connection", (socket) => {
    console.log("connected!");
    console.log(socket.id);
    socket.on("createRoom", async ({ nickname }) => {
        console.log(nickname);
        try {
            let room = new Room();
            let player = {
                socketID: socket.id,
                nickname,
                playerType: 'X',
            };
            room.players.push(player);
            room.turn = player;
            room = await room.save(); //save to mongodb
            console.log(room);
            const roomId = room._id.toString(); //room id 

            socket.join(roomId);


            // room created 
            //go to next page
            io.to(roomId).emit('CreateRoomSuccess', room);

        } catch (e) {
            console.log(e);
        }
    });

    socket.on('joinRoom', async ({ nickname, roomId }) => {
  try {
    if (!roomId.match(/^[0-9a-fA-F]{24}$/)) {
      socket.emit('errorOccured', "Please enter a valid room id");
      return;
    }

    let room = await Room.findById(roomId);

    if (!room) {
      socket.emit('errorOccured', "Room not found");
      return;
    }

    // ✅ check occupancy
    if (room.players.length >= 2) {
      socket.emit('errorOccured', "The game is in progress");
      return;
    }

    const player = {
      nickname,
      socketID: socket.id,
      playerType: 'O',
    };

    room.players.push(player);
    room = await room.save();

    socket.join(roomId);
    
    io.to(roomId).emit('joinRoomSuccess', room);
    io.to(roomId).emit('updatePlayers',room.players);
    io.io(toomId).emit('updateRoom',room);

  } catch (e) {
    console.log(e);
    socket.emit('errorOccured', "Something went wrong");
  }
});

});

Mongoose.connect(DB).then(() => {
    console.log("connection successful")
}).catch((e) => { console.log(e) });

server.listen(port, '0.0.0.0', () => {
    console.log('server started on port ' + port);
});