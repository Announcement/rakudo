subset CompUnit::PrecompilationId of Str:D
    where { 2 < .chars < 64 && $_ ~~ /^<[A..Za..z0..9._-]>+$/ };

role CompUnit::PrecompilationDependency {
    method id(--> CompUnit::PrecompilationId) { ... }
    method src(--> Str) { ... }
    method spec(--> CompUnit::DependencySpecification) { ... }
    method Str() {
        "$.id $.src $.spec"
    }
    method serialize(--> Str) { ... }
    method deserialize(Str, --> CompUnit::PrecompilationDependency) { ... }
}

role CompUnit::PrecompilationUnit {
    method id(--> CompUnit::PrecompilationId) { ... }
    method path(--> IO::Path) { ... }
    method modified(--> Instant) { ... }
    method dependencies(--> Array[CompUnit::PrecompilationDependency]) { ... }
    method bytecode(--> Buf) { ... }
    method checksum(--> Str) { ... }
    method bytecode-handle(--> IO::Handle) { ... }
}

class CompUnit::PrecompilationDependency::File does CompUnit::PrecompilationDependency {
    has CompUnit::PrecompilationId $.id;
    has Str $.src;
    has Str $.checksum is rw;
    has CompUnit::DependencySpecification $.spec;

    method source-name() {
        "$.src ($.spec.short-name())"
    }

    method deserialize(Str $str) {
        use MONKEY-SEE-NO-EVAL;
        my ($id, $src, $checksum, $spec) = $str.split("\0", 4);
        self.new(:$id, :$src, :$checksum, :spec(EVAL $spec));
    }

    method serialize(--> Str) {
        "$.id\0$.src\0$.checksum\0{$.spec.perl}"
    }

    method Str() {
        "$.id $.src $.checksum $.spec"
    }
}

# vim: ft=perl6 expandtab sw=4
