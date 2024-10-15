This Rails application effectively communicates the status message to the patient after they have submitted a treatment application.

It comes packaged with the following models:
* User
* Message
* Inbox
* Outbox
* Payment
When a user sends a message, it goes into their outbox and into the inbox of the recipient.

### Get up & running

Running `rails db:seed` will:

- Create a patient, admin and doctor user
- Create an inbox and outbox for each of the created users
- Create a message from a doctor to a patient, which thanks them for applying for a treatment

Run the server using `bin/dev`

### UseCase: 1

Patients should have the ability to send a message to their doctor through the app.

However, a message should only be sent to a doctor if the message they reply to was created in the past week.
If that message was created more than a week ago then the message should be routed to an Admin.

After submitting the form, the application should:

1. Create a new message, marked as unread
2. Update the senders outbox
3. Update the recipients inbox

Notes:

1. You can assume there will only be one doctor in the DB.
2. You don't need to worry about sessions or security. You can call User.current to return the only patient in the system.
3. Your design should assume that a doctor will have **hundreds of thousands of messages** in their inbox.

#### Testing

Please write tests for the following:

1. That a message has an unread status after creation
2. That a message is sent to the correct inbox and outbox after creation
 
### UseCase 2

Doctors have requested the ability to quickly see how many unread messages they have in their inbox. Add a new column to Inbox that reflects this number. Update this number when a message has been sent to the doctor.

#### Testing

Please write tests for the following:

1. That the number of unread messages is decremented when a doctor reads a message
2. That the number of unread messages is incremented when a doctor is sent a message


### UseCase 3

Patients regularly lose their prescription notes. An admin can re-issue a prescription note on behalf of a doctor. Update the application as follows:

1. When the patient clicks the "I've lost my script, please issue a new one at a charge of €10" button, it should send a hardcoded message to an admin requesting a new script
2. An API request to our Payment Provider should be called (this simply involves calling PaymentProviderFactory.provider.debit(amount))
3. A new Payment record should be created

Be careful: Default one is very flaky and fails 50% of the time.

#### Testing

Please write tests for the following:

1. A lost script message is sent to the admin and the Payment API is called and Payment Record is created
2. The call to the Payment API fails for some reason - ensure that the application gracefully degrades


## Instructions

1. Navigate to the project directory in your terminal.
2. Install Bundler if you haven't already:
```
 gem install bundler
```
3. Install the project dependencies by running:
```
 bundle install
```
4. Set up the database:
```
 rails db:create db:migrate
```
5.Seed the database with initial data:
```
 rails db:seed
```
6. To populate the database with a large number of messages for testing purposes, run the custom rake task:
```
 rails messages:insert
```
  This will insert 100,000 messages into the Message table. Note that this operation may take some time to complete.

7. For development and testing mails, set up Mailcatcher:
```
 gem install mailcatcher
 mailcatcher
```
8. Sidekiq is used for background job processing. Make sure to start Sidekiq in development:
```
 bundle exec sidekiq
```
9. To run the development server:
```
 bin/dev
```
10. Running server in development mode
```
Open web browser and navigate to http://localhost:3000/ to access the application 
```
11. To run tests:
```
 rspec .
```
12. For styling, the project uses Bootstrap

Still project has lot of scope for improvement in terms of UI 

Note: ***The seed file and rake task for inserting messages are particularly important for setting up a realistic testing environment with a large volume of data.*

## Below are accomplished as part of code-challenge:

### UseCase 1: 

### Messaging Enhancements
- Implemented Messaging Logic: Patients can now send messages to their doctors. If the original message is older than a week, the message is routed to an Admin. 
- Upon submission: A new message is created with an "unread" status.
The sender’s outbox and the recipient’s inbox are updated accordingly.
  #### Testing:

    - Verified that messages are marked as unread upon creation.
    - Ensured correct updating of outbox and inbox after message creation.

### UseCase 2: Unread Messages Count
- Added Unread Messages Counter: A new column in the Inbox model tracks the number of unread messages for doctors. This counter is updated when messages are sent or read.
  #### Testing:

    - Confirmed that the unread messages count decrements when a message is read.
    - Verified that the count increments when a new message is received.

### UseCase 3: Prescription Request and Payment Integration:

#### Enhanced Functionality: 
- Patients can now request a new prescription via a button. 

_This request initiates:_
- A message to be sent to an Admin.
- An API call to the Payment Provider to process the payment.
- A new column valid_until, is used to determine the prescription's expiry status. Patients are allowed to request a new prescription only if it is within the validity period. 
- If the prescription has expired, patients will need to book an appointment this flow is not implemented but can be included as further flow

#### Notification System: 
- After processing the payment, both the Admin and the patient receive an email notification about the status of the prescription, whether the payment is successful or not.

#### Error Handling: 
- Implemented comprehensive error handling for potential API failures to ensure the application degrades gracefully and maintains a smooth user experience.

### Testing:

- Confirmed that a prescription request message is correctly sent to the Admin and that the Payment API is called, creating a corresponding Payment record.
- Verified that the application handles payment API failures appropriately, maintaining functionality and user experience.

## Taken Care of: 

### Database Query Optimizations:
* Implemented efficient pagination to handle large datasets.
* Utilized ActiveRecord select queries to minimize data retrieval.
* Applied strategic database indexing on frequently accessed columns to enhance query performance.
* Optimized join operations by creating indexes on foreign key columns.
* Implemented composite indexes for queries involving multiple columns in WHERE clauses.
* Regularly analyze and update index statistics to ensure optimal query execution plans.
* Monitored query performance and adjusted indexing strategy based on usage patterns.

 These optimizations demonstrate a proactive approach to database performance, balancing the benefits of indexing with the overhead of maintaining indexes. By strategically applying indexes and continuously monitoring their effectiveness, you've created a robust foundation for efficient data retrieval and query execution.

### Error Handling and Logging:

 - Currently, I have used Rails.logger for logging errors. 
 - However, adopting a more comprehensive logging solution like integrating with external services such as Sentry for error monitoring could provide better insights into production issues.

### Code Quality and Linting:

- Although I have cleared most of the Rubocop linting errors, there is still scope for improvement using rubocop gems mentioned under tools group in Gemfile

### User Interface Enhancements:
- Although Bootstrap is currently in use, there’s an opportunity to elevate the design with a more refined and intuitive user interface. Introduce additional responsive and interactive elements to further enhance the user experience.

### Background Processing:
- Used Sidekiq for handling long-running tasks asynchronously, such as sending messages and processing payments

### Email Handling: 
- In development and testing, MailCatcher is used for managing emails. For a more robust solution in the production environment, integrating SendGrid can enhance email delivery and overall performance.

### Internationalization Support:

- I have added new keys into the en.yml file and utilized them throughout the project to facilitate easy translation and adaptation. 
- This approach ensures that the application can be seamlessly translated into various languages, thereby enhancing its accessibility and user experience across different linguistic regions.
