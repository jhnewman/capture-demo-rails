
Description
===========

A port of the janrain capture demo(Capture.Demo) from php into a ruby on rails app(Capture.Demo-rails).

The most recent version allows viewing all screens for multiple capture apps.

These can be selected from dropdown menus in the navigation bar, or accessed by the url '&lt;site&gt;/&lt;app_name&gt;/&lt;screen_name&gt;'

For example 'http://mysite.com/fox/public_profile'

Installation and Setup
======================

* Clone.

  git clone https://github.com/jhnewman/Capture.Demo-rails.git

* Run the exporter.rb rails runner script on a CaptureUI server to generate 'config.yml' and place in the rails root directory. A hypothetical scenario, for example:

  cd CaptureUI
  rails runner ../Capture.Demo-rails/exporter.rb ../Capture.Demo-rails/config.yml

* Start rails server.

  rails server -p 8001

Documentation
=============

exporter.rb
-----------

A rails runner script that exports configuration data from a CaptureUI server.
Execute the following command in the rails root directory of a CaptureUI server.

rails runner &lt;path-to-exporter&gt; [&lt;output-file&gt;]

The default &lt;output-file&gt; is 'config.yml'

DemoController
--------------

Controller for capture application screens, such as 'fox/signin', and back-end actions

* &lt;app name&gt;/authCallback
  Handles authentication callback from capture
* &lt;app name&gt;/logout
  Signs out of site, mostly for callbacks from sso sites.
* &lt;app name&gt;/xdcomm
  For cross domain scripts.

DemoController also populates variables used by partials

* _navigation.html.erb
  Renders welcome message and links to site pages.
* _backplane.html.erb
  Includes and configures backplane.
* _sso.html.erb
  Includes and configures SSO.

Layouts and Views
-----------------

Views are rendered within a single layout, demo_layout, which also renders the navigation bar, sso and backplane partials.

Helpers
-------

* SessionHelper
  Tracks signin state using the session hash, and exposes the capture api, specifically settings/items and entity.
  SessionHelper can maintain sessions for multiple capture applications.
* Settings
  Loads configuration from config.yml in rails root.

