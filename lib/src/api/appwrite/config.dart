import 'package:appwrite/appwrite.dart';

class AppWriteConfig {
  static Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("alquranaudio");
  static Account account = Account(client);
}
