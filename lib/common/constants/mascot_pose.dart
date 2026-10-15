/// Represents the available poses for the mascot illustration.
enum MascotPose {
  /// The mascot waving hello.
  wave('assets/mascot/mascot_wave.png'),

  /// The mascot writing or taking notes.
  writing('assets/mascot/mascot_writing.png'),

  /// The mascot celebrating success.
  success('assets/mascot/mascot_success.png');

  /// Creates a [MascotPose] with its associated asset [path].
  const MascotPose(this.path);

  /// The relative asset path to the pose image.
  final String path;
}
