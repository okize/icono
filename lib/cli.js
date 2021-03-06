const path = require('path');
const fs = require('fs');
const yargs = require('yargs');
const iconr = require('./app');

const pkg = require('../package.json');
const options = require('../lang/options.json');

// output version number of app
const getVersion = () => pkg.version;

// output help documentation of app
const getHelpText = () => {
  const helpFile = path.join(__dirname, '..', 'lang', 'help.txt');
  return fs.readFileSync(helpFile, 'utf8');
};

// create options object from cli arguments
const parseArguments = (args) => {
  const parsedOptions = {};

  options.forEach((opt) => {
    const value = args[opt.longName] || args[opt.shortName];
    switch (opt.type) {
      case 'string':
        parsedOptions[opt.longName] = value || null;
        break;
      case 'boolean':
        parsedOptions[opt.longName] = value === true;
        break;
      default:
        throw new Error('Options need to have a type specified');
    }
  });

  return parsedOptions;
};

const printHelp = () => console.log(`\n${getHelpText()}\n`);

module.exports = (process) => {
  const args = yargs.parse(process.argv);
  const commands = args._.slice(2, 4);

  // --version
  if (args.version || args.V) {
    return console.log(getVersion());
  }

  // --help
  if (args.help || args.h) {
    return printHelp();
  }

  // at least one command sent
  if (commands.length) {
    return iconr(commands, parseArguments(args));
  }

  // display help as default
  return printHelp();
};
