# Some things to do post hack-week:

1. Split up Feeds into two classes: KnownFeeds: list of feeds by url
                                    Feeds -- these refer to the nodes they're in

1. Add Articles: 
   - id
   - feed_id
   - published_on
   - title
   - description
   - content (for html)

-- This makes them easier to retrieve

1. Look at Chris's feedjira library:
gem 'feedjira'
gem 'httparty'

feed = nil

1. Feedjira.parsers.map { |parser| parser.parse(xml).entries }.compact

Compare these results here with the std RSS library and choose the best one.
Convert to Articles with the above features

1. Do we need to maintain a feeds_users table?

1. Delete aged articles once they're no longer in the feed.  Allow for requests to fail.

## UI improvements:

- Provide a way for users to add new KnownFeeds and admins can vet them

- Solve the tree-widget problem.  Maybe it's a bad idea to store those dummy UL nodes -- try rebuilding the tree with jstree

## General

1. Run this on a server

1. With https for all but the Home page
