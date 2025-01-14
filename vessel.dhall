let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.9.6/package-set.dhall
let Package = { name : Text, version : Text, repo : Text, dependencies : List Text }
let additions = [
  { name = "base"
  , repo = "https://github.com/dfinity/motoko-base"
  , version = "moc-0.9.6"
  , dependencies = [] : List Text
  }
] : List Package

in  { dependencies = additions
    , compiler = Some "0.9.6"
    }
