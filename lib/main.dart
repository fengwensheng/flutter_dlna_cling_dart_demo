import 'package:dlna/dlna.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter dlna-cling-dart Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //data field
  //method
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  //data field
  final _dlnaManager = DLNAManager();
  List<DLNADevice> _devices = []; //本地自行维护一个设备列表
  DLNADevice _currentDevice = DLNADevice();
  //
  VideoObject _videoObject = VideoObject(
    'Video Title',
    'http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4',
    VideoObject.VIDEO_MP4,
  );
  AnimationController _animationController;
  bool _isPlaying = false;
  //method
  _handleResearched() {
    _devices.clear();
    _dlnaManager.forceSearch();
    setState(() {});
  }

  _handleStopped() {
    _currentDevice = null;
    _devices.clear();
    _dlnaManager.actStop();
    setState(() {});
  }

  set setDlnaDevice(DLNADevice device) {
    _currentDevice = device;
    _dlnaManager.setDevice(device);
    _dlnaManager.actSetVideoUrl(_videoObject);
    setState(() {});
  }

  _handlePlayVideo() {
    _isPlaying = !_isPlaying;
    if (_isPlaying) {
      _dlnaManager.actPause();
      _animationController.reset();
      _animationController.reverse();
    } else {
      _dlnaManager.actPlay();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void initState() {
    super.initState();
    _dlnaManager.enableCache();
    _dlnaManager.startSearch();
    _dlnaManager.setRefresher(
      DeviceRefresher(
        onDeviceAdd: (currentDevice) {
          print('callback [onDeviceAdd]');
          if (_devices.contains(currentDevice)) return;
          _devices.add(currentDevice);
          setState(() {});
          print('current-device: ${currentDevice.toString()}');
          print('devices: ${_devices.toString()}');
        },
        onDeviceRemove: (currentDevice) {
          print('callback [onDeviceRemove]');
          if (!_devices.contains(currentDevice)) return;
          _devices.remove(currentDevice);
          setState(() {});
          print('current-device: ${currentDevice.toString()}');
          print('devices: ${_devices.toString()}');
        },
      ),
    );
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _handleResearched,
            child: Icon(Icons.refresh),
          ),
          SizedBox(width: 20),
          FloatingActionButton(
            onPressed: _handleStopped,
            child: Icon(Icons.stop),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'Flutter dlna-cling-dart Demo',
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      primary: true,
      padding: EdgeInsets.all(20),
      children: [
        _buildCurrentDevice(),
        SizedBox(height: 30.0),
        _buildDevices(),
        SizedBox(height: 30.0),
        _buildPlayBtn(),
      ],
    );
  }

  Widget _buildCurrentDevice() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'current selected DEVICE is: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${_currentDevice == null ? '请选择设备' : _currentDevice.deviceName}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[900],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDevices() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _devices.length,
      itemBuilder: (_, i) => Row(
        children: [
          Row(
            children: [
              Text(
                '${i + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.tv),
            ],
          ),
          Expanded(
            child: ListTile(
              onTap: () => setDlnaDevice = _devices[i],
              title: Text('${_devices[i].deviceName}'),
              subtitle: Text('${_devices[i].toString()}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayBtn() {
    return IconButton(
      onPressed: _handlePlayVideo,
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        color: Colors.blue,
        size: 50.0,
        progress: _animationController,
      ),
    );
  }

  ///end
}
