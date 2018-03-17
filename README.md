# Magic The Gathering Cards

This is solution for https://gist.github.com/christos/d80248f21cbb722800561bdb7b79ac59 challenge.

Ruby 2.5.0

## Installation

```
git clone git@github.com:Landria/magic_the_gathering_cards.git
cd magic_the_gathering_cards && bundle install
```

## Usage

You can run cards fetcher from command line or include the lib in your own solutoin.

### Command line usage

* Use **-g** or **--group** option to set attributes to group_by.
* Use **-c** or **--color** option to set colors to fectch.
* Use **-t** or **--type** option to set type attribute to fetch.
* Use **-s** or **--setName** option to set setName attribute to fetch.
* Use **-p** or **--pages** option to set number of pages to fetch.
* Use **-l** or **--legalities** option to set legalities format to fetch.
* Use **-f** or **--fields** option to set custom field/value to fetch.

By default fetching is not strong. Ex.: if red and blue colors a passed, all cards with red OR blue colors attributes will be fetched. Type and setName checks using regexp and will fetch all partial inclusions.

```
bin/magic_the_gathering_cards -g set,rarity -c red,blue -t Legendary -p 10
bin/magic_the_gathering_cards -p 3 -l Khans of Tahrir
 bin/magic_the_gathering_cards -p 3 -f legalities,Khans

```