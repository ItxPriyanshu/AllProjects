require('dotenv').config();
const express = require('express');
const http = require('http');
const Mongoose = require('mongoose');
const app = express();
var server = http.createServer(app);
const Room = require('./models/rooms')
var io = require('socket.io')(server);


//middleware
app.use(express.json());

const DB = process.env.MONGO_URI;
const port = process.env.PORT || 3000;



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
      io.to(roomId).emit('updatePlayers', room.players);
      io.to(roomId).emit('updateRoom', room);

    } catch (e) {
      console.log(e);
      socket.emit('errorOccured', "Something went wrong");
    }
  });
  socket.on('tap', async ({ index, roomId }) => {
    try {
      let room = await Room.findById(roomId);
      if (!room) return;
      let choice = room.turn.playerType; //X or O
      if (room.turnIndex == 0) {
        room.turn = room.players[1];
        room.turnIndex = 1;
      } else {
        room.turn = room.players[0];
        room.turnIndex = 0;
      }
      room = await room.save();
      io.to(roomId).emit('tapped', {
        index,
        choice,
        room,
      })
    } catch (e) {
      console.log(e);
    }
  });
  socket.on('winner', async ({ winnerSocketId, roomId }) => {
    try {
      let room = await Room.findById(roomId);
      let player = room.players.find((playerr) => playerr.socketID == winnerSocketId);

      player.points += 1;
      room = await room.save();

      if(player.points >= room.maxRounds){
        io.to(roomId).emit('endGame',player);
      }else{
        io.to(roomId).emit("pointIncrease",player);
      }
    } catch (e) {
      console.log(e);
    }
  })

});

Mongoose.connect(DB).then(() => {
  console.log("connection successful")
}).catch((e) => { console.log(e) });

server.listen(port, '0.0.0.0', () => {
  console.log('server started on port ' + port);
});