import 'package:grinder/grinder.dart';

main(args) => grind(args);

@Task('Run tests.')
test() => new TestRunner().testAsync();

@Task('Generate documentation.')
doc() => DartDoc.docAsync();

@Task('Publish package.')
publish() async {
}

@DefaultTask("Build.")
@Depends(test)
build() async {
}

@Task('Clean up.')
clean() => defaultClean();