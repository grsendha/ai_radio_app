import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:ai_radio/utils/ai_utils.dart';
import '../model/radio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:alan_voice/alan_voice.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<MyRadio> radios;
  MyRadio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;
  String playNow;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final sugg = [
    "play",
    'stop',
    'play rock music',
    'play 107 fm',
    'play next radio',
    'play 104 fm',
    'play previous fm',
    'play pop music',
    'pause',
  ];

  @override
  void initState() {
    super.initState();
    fetchRadios();
    setUpAlan();

    _audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  setUpAlan() {
    AlanVoice.addButton(
        "8058ced56c2dacd4f918946a5aba08a62e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_LEFT);
    AlanVoice.callbacks.add((command) => handleCommand(command.data));
  }

  handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        playMusic(_selectedRadio.url);
        print("command is ${response['command']}");
        break;
      case "stop":
        _audioPlayer.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index + 1 > radios.length) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index + 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
        break;
      case "prev":
        final index = _selectedRadio.id;
        MyRadio newRadio;
        if (index - 1 <= 0) {
          newRadio = radios.firstWhere((element) => element.id == 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        } else {
          newRadio = radios.firstWhere((element) => element.id == index - 1);
          radios.remove(newRadio);
          radios.insert(0, newRadio);
        }
        playMusic(newRadio.url);
        break;
      case "play_channel":
        final id = response['id'];
        _audioPlayer.pause();
        MyRadio newRadio = radios.firstWhere((element) => element.id == id);
        radios.remove(newRadio);
        radios.insert(0, newRadio);
        playMusic(newRadio.url);
        break;
    }
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString('assets/radio.json');
    radios = MyRadioList.fromJson(radioJson).radios;
    _selectedRadio = radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));

    print(radios.length);
    setState(() {});
  }

  playMusic(String url) {
    _audioPlayer.play(UrlSource(url));
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    playNow=_selectedRadio.name;
    debugPrint(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor ?? AIColors.primaryColor2,
          child: radios != null
              ? VStack(
                  [
                    60.heightBox,
                    "All Channel".text.xl2.bold.white.make().p16(),
                    // 10.heightBox,
                    ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(5),
                      children: radios
                          .map(
                            (e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: Text(
                                "${e.category} FM",
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: e.tagline.text.white.make(),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  crossAlignment: CrossAxisAlignment.start,
                )
              : const Offstage(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        // clipBehavior: Clip.antiAlias,
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    _selectedColor ?? AIColors.primaryColor1,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          VStack(
            [
              AppBar(
                title: "AI Radio".text.xl4.bold.white.make().shimmer(
                    primaryColor: Vx.purple300, secondaryColor: Colors.white),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ).h(100).p16(),
              // 10.heightBox,
              "Start With - Hey Alan".text.italic.semiBold.white.make(),
              20.heightBox,
              VxSwiper.builder(
                autoPlay: true,
                autoPlayAnimationDuration: 3.seconds,
                viewportFraction: 0.45,
                height: 50,
                autoPlayCurve: Curves.linear,
                itemCount: sugg.length,
                itemBuilder: ((context, index) {
                  final c = sugg[index];
                  return SizedBox(
                    child: "\"${c}\"".text.white.italic.make(),
                  );
                }),
              ),
            ],
            crossAlignment: CrossAxisAlignment.center,
          ),
          30.heightBox,
          radios != null
              ? VxSwiper.builder(
                  aspectRatio: 1.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    _selectedRadio = radios[index];
                    final colorHex = radios[index].color;
                    _selectedColor = Color(int.tryParse(colorHex));
                    setState(() {});
                  },
                  itemCount: radios.length,
                  itemBuilder: (context, index) {
                    final rad = radios[index];
                    return VxBox(
                      child: ZStack(
                        [
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: VxBox(
                                    child: rad.category.text.uppercase.white
                                        .make()
                                        .px16())
                                .height(40)
                                .withRounded(value: 10)
                                .black
                                .alignCenter
                                .make(),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: VStack(
                              [
                                rad.name.text.xl3.white.bold.make(),
                                const SizedBox(height: 5),
                                rad.tagline.text.sm.white.semiBold.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: VStack(
                              [
                                const Icon(
                                  CupertinoIcons.play_circle,
                                  color: Colors.white,
                                  size: 80,
                                ),
                                const SizedBox(height: 10),
                                "Double Tap to play".text.gray300.make(),
                              ],
                              crossAlignment: CrossAxisAlignment.center,
                            ),
                          )
                        ],
                      ),
                    )
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)),
                        )
                        .withRounded(value: 60)
                        .border(color: Colors.black, width: 4)
                        .make()
                        .onInkDoubleTap(() {
                      playMusic(rad.url);
                    }).p16();
                  },
                ).centered()
              : const Center(
                  child:
                      CircularProgressIndicator(backgroundColor: Colors.white),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: VStack(
              [
                if (_isPlaying)
                  Text("Playing Now $playNow FM",
                          textAlign: TextAlign.center)
                      .centered(),
                SizedBox(height: 8),
                Icon(
                  _isPlaying
                      ? CupertinoIcons.stop_circle
                      : CupertinoIcons.play_circle,
                  color: Colors.white,
                  size: 50,
                ).centered().onInkTap(() {
                  if (_isPlaying) {
                    _audioPlayer.stop();
                  } else {
                    playMusic(_selectedRadio.url);
                  }
                }),
              ],
            ),
          ).pOnly(bottom: context.percentHeight * 12),
        ],
      ),
    );
  }
}
