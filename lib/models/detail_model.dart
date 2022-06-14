class DetailModel {
  DetailModel(
      {required this.id,
      required this.storeId,
      required this.owner,
      required this.namaToko,
      required this.daerah,
      required this.fotoToko,
      required this.namaBarang,
      required this.harga,
      required this.deskripsi,
      required this.kategori,
      required this.fotoBarang,
      required this.diskon,
      this.totalBarang,
      this.totalHarga,
      this.alamat});
  int id;
  int storeId;
  int owner;
  String namaToko;
  String fotoToko;
  String namaBarang;
  String daerah;
  int harga;
  String deskripsi;
  String kategori;
  String fotoBarang;
  int? diskon;
  int? totalBarang;
  int? totalHarga;
  String? alamat;
}
