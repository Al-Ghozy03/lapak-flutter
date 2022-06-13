class SearchValue {
  int storeId;
  int id;
  int owner;
  String namaToko;
  String daerah;
  String fotoToko;
  String namaBarang;
  int harga;
  String deskripsi;
  int diskon;
  String fotoBarang;
  SearchValue(
      {required this.daerah,
      required this.deskripsi,
      required this.diskon,
      required this.fotoBarang,
      required this.fotoToko,
      required this.harga,
      required this.id,
      required this.namaBarang,
      required this.namaToko,
      required this.owner,
      required this.storeId});
}
