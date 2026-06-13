# EventHub UI Selectors Reference (Robot Framework + SeleniumLibrary)

## Login Page
- Email input: `css:input[placeholder='you@email.com']` or `xpath://label[normalize-space()='Email']//following-sibling::input | //label[normalize-space()='Email']/..//input`
- Password input: `xpath://label[normalize-space()='Password']/..//input` or `css:input[type='password']`
- Login button: `id:login-btn`

## Home Page
- Browse Events link: `xpath://a[normalize-space()='Browse Events ->']`
- My Bookings link: `xpath://nav//a[contains(normalize-space(),'My Bookings')]`

## Events Page
- Event cards: `css:[data-testid='event-card']`
- Book Now button: `css:[data-testid='book-now-btn']` (inside card)
- Sandbox banner: `xpath://*[contains(translate(normalize-space(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'sandbox holds up to')]`
- Category/City/Search filters: `xpath://select[@name='category']` / `xpath://select[@name='city']` / `css:input[type='search']`

## Event Detail / Booking Form
- Ticket count display: `id:ticket-count`
- Increment/Decrement: `xpath://button[normalize-space()='+']` / `xpath://button[normalize-space()='-']`
- Full Name: `xpath://label[normalize-space()='Full Name']/..//input`
- Email: `id:customer-email`
- Phone: `css:input[placeholder='+91 98765 43210']`
- Confirm: `css:.confirm-booking-btn`
- Booking Ref: `css:.booking-ref`

## Admin Event Form
- Title: `id:event-title-input`
- Description: `css:#admin-event-form textarea`
- City: `xpath://label[normalize-space()='City']/..//input`
- Venue: `xpath://label[normalize-space()='Venue']/..//input`
- Date: `xpath://label[normalize-space()='Event Date & Time']/..//input`
- Price: `xpath://label[contains(normalize-space(),'Price')]/..//input`
- Seats: `xpath://label[normalize-space()='Total Seats']/..//input`
- Add button: `id:add-event-btn`

## Bookings Page
- Booking cards: `css:[id='booking-card']`
- View Details link: `xpath://a[normalize-space()='View Details']`
- Clear all link: `xpath://a[contains(normalize-space(),'Clear all') or contains(normalize-space(),'Clear All')]`

## Booking Detail Page
- Booking ref: `css:span.font-mono.font-bold`
- Event title: `css:h1`
- Check refund: `id:check-refund-btn`
- Refund spinner: `id:refund-spinner`
- Refund result: `id:refund-result`
- Cancel button: `xpath://button[contains(normalize-space(),'Cancel')]`
