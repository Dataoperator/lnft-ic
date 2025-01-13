{
  dependencies = [
    {
      name = "base",
      repo = "https://github.com/dfinity/motoko-base",
      version = "master",
      dependencies = [] : List Text
    },
    {
      name = "array",
      repo = "https://github.com/aviate-labs/array.mo",
      version = "master",
      dependencies = [ "base" ]
    },
    {
      name = "hash",
      repo = "https://github.com/aviate-labs/hash.mo",
      version = "master",
      dependencies = [ "base" ]
    },
    {
      name = "encoding",
      repo = "https://github.com/aviate-labs/encoding.mo",
      version = "master",
      dependencies = [ "base", "array" ]
    },
    {
      name = "principal",
      repo = "https://github.com/aviate-labs/principal.mo",
      version = "master",
      dependencies = [ "array", "encoding" ]
    }
  ],
  compiler = None Text
}