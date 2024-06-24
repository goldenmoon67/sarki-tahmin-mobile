import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:default_flutter_project/src/modules/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late IO.Socket socket;
  Map<String, dynamic>? currentSong;
  int score = 0;
  YoutubePlayerController? _controller;
  String? selectedOption;
  String? correctOption;
  Map<String, String>? answers;
  int timer = 30;
  late Timer _timer;
  String? roomId;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://10.0.2.2:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('room_created', (data) {
      setState(() {
        roomId = data;
      });
      print('Room created with ID: $roomId');
      joinRoom(roomId!); // Automatically join the room after creation
    });

    socket.on('song', (data) {
      print('New song received: $data');
      setState(() {
        currentSong = data;
        selectedOption = null;
        correctOption = null;
        answers = null;
        timer = 30;
        if (_controller == null) {
          _controller = YoutubePlayerController(
            initialVideoId: YoutubePlayer.convertUrlToId(data['url'])!,
            flags: YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
            ),
          );
        } else {
          _controller!.load(YoutubePlayer.convertUrlToId(data['url'])!);
        }
      });
      startTimer();
    });

    socket.on('answers_summary', (data) {
      setState(() {
        correctOption = data['correctOption'];
        answers = Map<String, String>.from(data['answers']);
      });
      stopTimer();
      Future.delayed(Duration(seconds: 10), () {
        setState(() {
          selectedOption = null;
          correctOption = null;
          answers = null;
        });
      });
    });

    socket.on('game_over', (data) {
      // Show game over screen or scores
      print('Game Over: $data');
      // You can add UI to show final scores here
    });

    socket.on('error', (data) {
      // Handle error
      print('Error: ${data['message']}');
    });

    socket.on('disconnect', (_) {
      print('Disconnected from server');
    });
  }

  void createRoom() {
    socket.emit('create_room');
  }

  void joinRoom(String roomId) {
    socket.emit('join_room', roomId);
    setState(() {
      this.roomId = roomId;
    });
  }

  void sendAnswer(String answer) {
    setState(() {
      selectedOption = answer;
    });
    socket.emit('answer', {'roomId': roomId, 'answer': answer});
    stopTimer(); // Stop the timer when an answer is sent
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (this.timer > 0) {
        setState(() {
          this.timer -= 1;
        });
      } else {
        stopTimer();
        sendAnswer('No Answer');
      }
    });
  }

  void stopTimer() {
    if (_timer.isActive) {
      _timer.cancel();
    }
  }

  Color getOptionColor(String option) {
    if (selectedOption == option) {
      if (correctOption == null) {
        return Colors.grey;
      }
      return correctOption == option ? Colors.green : Colors.red;
    }
    if (correctOption != null && correctOption == option) {
      return Colors.green;
    }
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc(),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          //TODO:: add listeners for states
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Music Quiz App'),
            ),
            body: roomId == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: createRoom,
                          child: Text('Create Room'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onSubmitted: joinRoom,
                            decoration: InputDecoration(
                              labelText: 'Enter Room ID to Join',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : currentSong == null
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_controller != null)
                            YoutubePlayer(
                              controller: _controller!,
                              showVideoProgressIndicator: true,
                            ),
                          Text('Current Song: ${currentSong!['title']}'),
                          Text('Time left: $timer seconds'),
                          ...currentSong!['options'].map<Widget>((option) {
                            return ElevatedButton(
                              onPressed: correctOption == null
                                  ? () => sendAnswer(option)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: getOptionColor(option),
                              ),
                              child: Text(option),
                            );
                          }).toList(),
                          if (answers != null)
                            Column(
                              children: [
                                Text(
                                  'Correct Option: $correctOption',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                ...answers!.entries.map<Widget>((entry) {
                                  return Text(
                                    'User ${entry.key}: ${entry.value == correctOption ? "Correct" : "Wrong"}',
                                    style: TextStyle(fontSize: 18),
                                  );
                                }).toList(),
                              ],
                            ),
                          Text('Your Score: $score'),
                        ],
                      ),
          );
        },
      ),
    );
  }
}
