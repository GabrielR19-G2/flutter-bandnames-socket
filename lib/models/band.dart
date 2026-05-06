class Band {
  //
  String id; // viene del backend
  String name;
  int votes;

  // {} -> con nombre
  Band({required this.id, required this.name, required this.votes});

  // factory -> recibe cierto tipo de argumentos y regresa una nueva instancia de la clase
  factory Band.fromMap(Map<String, dynamic> obj) => Band(
    id: obj.containsKey('id') ? obj['id'] : "no-id",
    name: obj.containsKey('name') ? obj['name'] : "no-name",
    votes: obj.containsKey('votes') ? obj['votes'] : "no-votes",
  );
}
