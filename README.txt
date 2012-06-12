
Description
===========

A port of the janrain capture demo site from php into a ruby on rails app.

The most recent version allows viewing all screens for multiple capture apps.

These can be selected from dropdown menus in the navigation bar, or accessed by the url '<site>/<app name>/<screen name>'

For example 'http://mysite.com/fox/public_profile'

Installation and Setup
======================

* Clone.

* Run the exporter.rb rails runner script to generate 'config.yml' and place in rails root directory.

* Start rails server.

Documentation
=============

exporter.rb
-----------

A rails runner script that exports configuration data from a CaptureUI server.
Execute the following command in the rails root directory of a CaptureUI server.

rails runner <path-to-exporter> [<output-file>]

The default <output-file> is 'config.yml'

DemoController
--------------

Controller for capture application screens, such as 'fox/signin', and back-end actions

* <app name>/authCallback
  Handles authentication callback from capture
* <app name>/logout
  Signs out of site, mostly for callbacks from sso sites.
* <app name>/xdcomm
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

