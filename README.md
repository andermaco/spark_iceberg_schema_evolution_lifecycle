# Schema Evolution with dbt and Athena

This project demonstrates schema evolution handling using dbt (data build tool) with AWS Athena. It implements a medallion architecture with bronze and silver layers, focusing on maintaining data quality and schema consistency.

## Project Structure 

## Layers

### Bronze Layer
- Raw data ingestion
- Minimal transformations
- Timestamp precision handling
- Basic data quality tests

### Silver Layer
- Business logic implementation
- Schema evolution handling
- Partitioned data storage
- Advanced data quality checks

## Tests

The project includes several data quality tests:

1. Schema Evolution Test
   - Tracks changes between source and transformed tables
   - Validates column consistency
   - Ensures data completeness

2. Data Quality Tests
   - Not null constraints
   - Unique key validation
   - Custom business rules

## Setup

1. Configure your AWS credentials:
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=eu-west-1
```

2. Configure dbt profile (`~/.dbt/profiles.yml`):
```yaml
demo:
  outputs:
    dev:
      type: athena
      s3_staging_dir: s3://your-bucket/path/
      region_name: eu-west-1
      schema: your_schema
      database: AwsDataCatalog
      aws_profile_name: default
      threads: 1
      work_group: primary
  target: dev
```

3. Install dependencies:
```bash
pip install -r requirements.txt
dbt deps
```

## Usage

1. Run all models:
```bash
dbt run
```

2. Run tests:
```bash
dbt test
```

3. Generate documentation:
```bash
dbt docs generate
dbt docs serve
```

## Schema Evolution Handling

The project includes custom tests and macros for handling schema evolution:

1. Column Addition Detection
2. Data Type Changes Validation
3. Automated Testing of Schema Changes

## Contributing

1. Create a feature branch:
```bash
git checkout -b feature/your-feature-name
```

2. Make your changes and commit:
```bash
git commit -m "feat: your feature description"
```

3. Push and create a pull request:
```bash
git push -u origin feature/your-feature-name
```

## Requirements

- Python 3.10+
- dbt 1.9.4
- AWS Account with Athena access
- AWS CLI configured

## Dependencies

```txt
dbt-core
dbt-athena
vulcan-sql
wheel
setuptools
```

## License

Apache License 2.0 

## Contact

andermaco@gmail.com