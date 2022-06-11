class MoreStore {
  MoreStore({
    required this.id,
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
  });
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
}
