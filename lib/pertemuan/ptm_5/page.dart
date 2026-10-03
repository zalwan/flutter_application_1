import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const Pertemuan5Page();

class Pertemuan5Page extends StatefulWidget {
  const Pertemuan5Page({super.key});

  @override
  State<Pertemuan5Page> createState() => _Pertemuan5PageState();
}

class _Pertemuan5PageState extends State<Pertemuan5Page> {
  String _lastGesture = 'Belum ada gesture';
  Color _tapBoxColor = Colors.blue.shade100;
  int _tapCount = 0;
  int _doubleTapCount = 0;
  int _longPressCount = 0;

  String _swipeDirection = '-';
  double _scale = 1.0;
  double _baseScale = 1.0;
  Offset _panOffset = Offset.zero;

  void _updateGesture(String message) {
    setState(() => _lastGesture = message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pertemuan 5 - GestureDetector')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StatusCard(lastGesture: _lastGesture),
            const SizedBox(height: 16),
            _SectionTitle(
              title: '1. Tap, Double Tap & Long Press',
              subtitle:
                  'onTap, onDoubleTap, onLongPress — counter bertambah tiap gesture.',
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _tapCount++;
                  _tapBoxColor = Colors.blue.shade300;
                });
                _updateGesture('onTap terdeteksi (tap ke-$_tapCount)');
              },
              onDoubleTap: () {
                setState(() {
                  _doubleTapCount++;
                  _tapBoxColor = Colors.green.shade300;
                });
                _updateGesture(
                  'onDoubleTap terdeteksi (ke-$_doubleTapCount)',
                );
              },
              onLongPress: () {
                setState(() {
                  _longPressCount++;
                  _tapBoxColor = Colors.orange.shade300;
                });
                _updateGesture(
                  'onLongPress terdeteksi (ke-$_longPressCount)',
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: _tapBoxColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blueGrey.shade100),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.touch_app, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Ketuk / ketuk 2x / tahan kotak ini',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap: $_tapCount   •   Double: $_doubleTapCount   •   Long: $_longPressCount',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: '2. Swipe / Drag',
              subtitle:
                  'onHorizontalDragEnd & onVerticalDragEnd untuk arah geser.',
            ),
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                final direction =
                    velocity > 0 ? 'Kanan ➡' : 'Kiri ⬅';
                setState(() => _swipeDirection = 'Horizontal: $direction');
                _updateGesture('Swipe horizontal ke $direction');
              },
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                final direction = velocity > 0 ? 'Bawah ⬇' : 'Atas ⬆';
                setState(() => _swipeDirection = 'Vertikal: $direction');
                _updateGesture('Swipe vertikal ke $direction');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade100),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.swipe, size: 40),
                    const SizedBox(height: 8),
                    const Text(
                      'Geser kotak ini ke atas / bawah / kiri / kanan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text('Arah terakhir: $_swipeDirection'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: '3. Pinch to Zoom (Scale)',
              subtitle: 'onScaleStart, onScaleUpdate, onScaleEnd.',
            ),
            GestureDetector(
              onScaleStart: (_) => _baseScale = _scale,
              onScaleUpdate: (details) {
                setState(() => _scale = (_baseScale * details.scale).clamp(
                  0.5,
                  3.0,
                ));
              },
              onScaleEnd: (_) =>
                  _updateGesture('Scale berakhir di ${_scale.toStringAsFixed(2)}x'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Column(
                  children: [
                    Transform.scale(
                      scale: _scale,
                      child: const Icon(
                        Icons.zoom_in,
                        size: 48,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cubit (pinch) untuk zoom ikon',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Skala: ${_scale.toStringAsFixed(2)}x'),
                    Slider(
                      value: _scale,
                      min: 0.5,
                      max: 3.0,
                      label: '${_scale.toStringAsFixed(2)}x',
                      onChanged: (v) => setState(() => _scale = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: '4. Drag / Pan (Geser Bebas)',
              subtitle: 'onPanUpdate untuk memindahkan widget.',
            ),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 120 + _panOffset.dx,
                    top: 60 + _panOffset.dy,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() => _panOffset += details.delta);
                      },
                      onPanEnd: (_) => _updateGesture(
                        'Pan berhenti di (${_panOffset.dx.toStringAsFixed(0)}, ${_panOffset.dy.toStringAsFixed(0)})',
                      ),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 6,
                              offset: Offset(0, 3),
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.open_with,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 12,
                    top: 12,
                    child: Text('Seret kotak kuning di area ini'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _lastGesture = 'Belum ada gesture';
                  _tapBoxColor = Colors.blue.shade100;
                  _tapCount = 0;
                  _doubleTapCount = 0;
                  _longPressCount = 0;
                  _swipeDirection = '-';
                  _scale = 1.0;
                  _panOffset = Offset.zero;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Semua'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.lastGesture});

  final String lastGesture;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.gesture, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gesture Terakhir',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(lastGesture),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 2),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
