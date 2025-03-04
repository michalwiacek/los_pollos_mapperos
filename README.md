# Los Pollos Mapperos

**Los Pollos Mapperos** is a CLI tool for updating GraphQL field definitions based on your database column types. It retrieves column information directly from your Rails application's database and updates the corresponding GraphQL object definitions using configurable mappings. Inspired by pop culture (a playful twist on "Los Pollos Hermanos"), this tool brings a fun yet practical approach to your schema updates.

## Features

- **Database Driven:** Automatically fetches column information from your application's database.
- **Configurable Mappings:** Define custom mappings to translate DB column types (e.g., bigint) to the appropriate GraphQL types.
- **Interactive CLI:** Guides you through selecting the correct GraphQL file and reviewing proposed changes with clear diff output.
- **Extendable:** Easily supports multiple column types with custom configurations.
- **Pop Culture Inspired:** A catchy, fun name that adds personality to your tool.

## Installation

### As a Gem

Add the following line to your application's Gemfile:

```ruby
gem 'los_pollos_mapperos'
```

Then run:
```
bundle install
```

Alternatively, install the gem manually:
```
gem install los_pollos_mapperos
```

From Source
Clone the repository and build the gem:

```
git clone https://github.com/michalwiacek/los_pollos_mapperos.git
cd los_pollos_mapperos
gem build los_pollos_mapperos.gemspec
gem install los_pollos_mapperos-0.1.0.gem
```

## Usage
### Configuration
Set up Los Pollos Mapperos in a Rails initializer (e.g., config/initializers/los_pollos_mapperos.rb):

```
LosPollosMapperos.configure do |config|
  # Example: Map columns whose SQL type matches "bigint" to GraphQL type Scalars::BigInt
  config.mappings[:bigint] = { regex: /bigint/i, graphql_type: "Scalars::BigInt" }

  # Add additional mappings as needed:
  # config.mappings[:custom_int] = { regex: /custom_int/i, graphql_type: "Scalars::CustomInt" }
end
```

## Running the CLI Tool
### From your Rails application's root directory, run the CLI tool with:

```
bin/los_pollos_mapperos
```

## The tool will:

- Load your Rails environment – ensuring access to your models and database.
- Connect to the database and fetch tables from the public schema.
- Identify columns matching the configured mappings.
- Locate corresponding GraphQL files in app/graphql/objects.
- Display proposed changes interactively (with a diff) for review.
- Update the GraphQL files upon your confirmation.
### Interactive Mode
- If multiple GraphQL files are found for a given model, you will be prompted to select the correct file.
- A diff of the proposed changes is shown so you can review and decide whether to apply them.
- You confirm each change by typing y (yes) or skip by entering n.
### Contributing
Contributions, bug reports, and feature requests are welcome! Please check out the GitHub repository for more details and instructions on how to contribute.

### License
Los Pollos Mapperos is available as open source under the MIT License.
