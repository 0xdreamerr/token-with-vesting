# Foundry Template

Run the command to start from this template

```shell
$ forge init --template <this-repo> <new-project-name>
```

## Features

### Script and test utils

> **Important Note:**
>
> It's recommended to use `*Helpers.sol` as instance of contract, not to inherit from them.

- read/write to a JSON file,
- powerful fork util
- chainId and eId lists

### Snippets

- `header comment` - print a comment block, which can be used to separate code into sections for readability
- `contract` - print contract with license, pragma and empty constructor
- `test setup contract` - print a setup for test contract (should use in ContractName.Setup.sol file)
- `test simple contract` - print a simple test contract with forge-std/Test.sol
- `script simple contract` - print a script contract with forge-std/Script.sol

### Examples

- Example of a contract structure
- Example of a test structure

### Ready to use

- public rpc in .env.example
- configured foundry.toml
