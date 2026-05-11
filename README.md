# Car On Rental

Car On Rental is a Salesforce Lightning application for managing a car rental business. The project contains Salesforce metadata for vehicle inventory, customer bookings, coupon approvals, payment tracking, review handling, case management, automation, and Lightning UI components.

## Features

- Car inventory management with make, model, fuel type, transmission, seats, rental rate, service dates, mileage limits, availability, and image support.
- Booking lifecycle management with start and end dates, cancellation handling, payment status, security deposit, refunds, adjustments, and final price calculations.
- Customer tracking through Contact fields for lifetime spending, booking count, and phone/email verification.
- Coupon code management with duplicate prevention, maximum discount validation, expiration checks, and approval routing.
- Payment transaction records linked to bookings.
- Customer reviews and car ratings with validation and display components.
- Case support for booking inquiries, maintenance requests, and review issues.
- Metadata-driven trigger framework for configurable trigger execution.
- Logging framework using platform events and custom log storage with cleanup automation.
- Lightning pages, quick actions, flows, queues, permission sets, and static car image resources.

## Tech Stack

- Salesforce DX project format
- Apex classes and triggers
- Lightning Web Components
- Aura components
- Salesforce Flows
- Custom Objects, Custom Metadata Types, Validation Rules, Approval Processes, Queues, and Permission Sets
- Jest for LWC unit tests
- ESLint and Prettier for code quality

## Project Structure

```text
force-app/main/default/
|-- applications/          # Car On Rental Lightning app
|-- aura/                  # Aura components
|-- classes/               # Apex services, controllers, tests, and trigger framework
|-- customMetadata/        # Trigger and system threshold configuration
|-- flows/                 # Booking, image sync, approval, and return automations
|-- flexipages/            # Lightning record pages and Car Hunt page
|-- layouts/               # Object page layouts
|-- lwc/                   # Lightning Web Components
|-- objects/               # Custom and standard object metadata
|-- permissionsets/        # User permission sets
|-- quickActions/          # Booking and car quick actions
|-- staticresources/       # Logo, rating assets, and car images
`-- triggers/              # Apex triggers
```

## Key Metadata

- **Application:** `Car_On_Rental`
- **Main custom objects:** `Car__c`, `Booking__c`, `Car_Image__c`, `Coupon_Code__c`, `Payment_Transaction__c`, `Review__c`, `LogEvent__c`
- **Custom metadata:** `Metadata_Driven_Trigger__mdt`, `System_Threshold__mdt`, `Disabled_For__mdt`
- **Main pages:** `Car_Hunt`, `Car_Record_Page`, `Booking_Record_Page`
- **Permission sets:** `Car_On_Rental`, `Rental_Manager_Permissions`
- **Primary LWC modules:** `carTileList`, `carTile`, `carCard`, `carFilter`, `bookCarModal`, `estimateCarBookingModal`, `carImageManager`, `carRatingReview`, `starRating`

## Prerequisites

- Salesforce CLI
- Node.js and npm
- A Salesforce org or scratch org
- Git

## Setup

Install project dependencies:

```bash
npm install
```

Authenticate to a Salesforce org:

```bash
sf org login web --alias car-on-rental
```

Deploy source metadata:

```bash
sf project deploy start --target-org car-on-rental
```

Assign the main permission set:

```bash
sf org assign permset --name Car_On_Rental --target-org car-on-rental
```

Open the org:

```bash
sf org open --target-org car-on-rental
```

## Scratch Org Setup

Create a scratch org:

```bash
sf org create scratch --definition-file config/project-scratch-def.json --alias car-on-rental-scratch --duration-days 30
```

Deploy metadata and assign permissions:

```bash
sf project deploy start --target-org car-on-rental-scratch
sf org assign permset --name Car_On_Rental --target-org car-on-rental-scratch
sf org open --target-org car-on-rental-scratch
```

## Development Commands

Run LWC unit tests:

```bash
npm test
```

Run LWC tests with coverage:

```bash
npm run test:unit:coverage
```

Run linting:

```bash
npm run lint
```

Format source files:

```bash
npm run prettier
```

Verify formatting:

```bash
npm run prettier:verify
```

## Apex Tests

Run all local Apex tests in the target org:

```bash
sf apex run test --test-level RunLocalTests --target-org car-on-rental --wait 10 --result-format human
```

Run a specific Apex test class:

```bash
sf apex run test --class-names BookingTriggerHandlerTest --target-org car-on-rental --wait 10 --result-format human
```

## Deployment Notes

- The project uses Salesforce API version `65.0`.
- The default package directory is `force-app`.
- Static resources include the application logo, star rating assets, and car images.
- Some automations depend on custom metadata records in `force-app/main/default/customMetadata`.
- The app navigation includes Home, Car Hunt, Contacts, Cars, Bookings, Coupon Codes, Cases, Reports, and Dashboards.

## Useful Salesforce Commands

Retrieve changes from an org:

```bash
sf project retrieve start --target-org car-on-rental
```

Validate deployment without saving changes:

```bash
sf project deploy validate --source-dir force-app --target-org car-on-rental
```

Generate a package manifest from source:

```bash
sf project generate manifest --source-dir force-app
```

## License

Created as part of a Udemy course for learning and portfolio purposes. Course materials and assets belong to their respective owners.
