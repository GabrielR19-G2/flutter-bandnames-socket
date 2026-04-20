class Band {
  //
  String id; // viene del backend
  String name;
  int votes;

  // {} -> con nombre
  Band({required this.id, required this.name, required this.votes});

  // factory -> recibe cierto tipo de argumentos y regresa una nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(id: obj['id'], name: obj['name'], votes: obj['votes']);
}
