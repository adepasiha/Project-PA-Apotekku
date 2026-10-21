String? productImageAssetForName(String name) {
  final normalizedName = name.toLowerCase();
  if (normalizedName.contains('paracetamol')) {
    return 'assets/images/paracetamol.png';
  }
  if (normalizedName.contains('amoxicillin')) {
    return 'assets/images/amoxicillin.png';
  }
  if (normalizedName.contains('vitamin c')) {
    return 'assets/images/vitamin_c.png';
  }
  if (normalizedName.contains('vitamin d')) {
    return 'assets/images/vitamin_d3.png';
  }
  if (normalizedName.contains('vitamin b')) {
    return 'assets/images/vitamin_b_kompleks.png';
  }
  if (normalizedName.contains('vitamin e')) {
    return 'assets/images/vitamin_e.png';
  }
  if (normalizedName.contains('ibuprofen')) {
    return 'assets/images/ibuprofen.png';
  }
  if (normalizedName.contains('amlodipine')) {
    return 'assets/images/amlodipine.png';
  }
  if (normalizedName.contains('metformin')) {
    return 'assets/images/metformin.jpg';
  }
  if (normalizedName.contains('loratadine')) {
    return 'assets/images/loratadine.jpg';
  }
  if (normalizedName.contains('antasida')) {
    return 'assets/images/antasida.jpg';
  }
  if (normalizedName.contains('zinc')) {
    return 'assets/images/zinc.png';
  }
  if (normalizedName.contains('multivitamin')) {
    return 'assets/images/multivitamin.jpg';
  }
  if (normalizedName.contains('kayu putih')) {
    return 'assets/images/minyak_kayu_putih.png';
  }
  if (normalizedName.contains('kunyit asam')) {
    return 'assets/images/kunyit_asam.png';
  }
  if (normalizedName.contains('jahe')) {
    return 'assets/images/jahe_merah.png';
  }
  if (normalizedName.contains('madu')) {
    return 'assets/images/madu_herbal.png';
  }
  if (normalizedName.contains('batuk') || normalizedName.contains('herbakof')) {
    return 'assets/images/herbakof.png';
  }
  return null;
}
