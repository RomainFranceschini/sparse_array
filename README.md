# SparseArray

A SparseArray maps integers to generic types. It allows gaps in incices, just like a Hash, but in a memory efficient manner. It is slower than a Hash though.

TODO:
- [ ] Support deletion
- [ ] Support Enumerable/Iterable
- [ ] dup/clone
- [ ] to_s/inspect

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sparse_array:
    github: rumenzu/sparse_array
```

## Usage

```crystal
require "sparse_array"
```

## Contributing

1. Fork it ( https://github.com/rumenzu/sparse_array/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [rumenzu](https://github.com/rumenzu) Romain Franceschini - creator, maintainer
