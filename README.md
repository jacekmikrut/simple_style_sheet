simple_style_sheet
==================

simple_style_sheet is a Ruby gem that **parses a CSS-like Hash style sheet** and then **allows searching for property values of given HTML-like tags**. Tag and property names, as well as their meaning, are up to the gem user.

Usage and details
-----------------

### 1. Style sheet preparation

The style sheet is just a CSS-like Hash object. Its keys are either selectors or property names, and values are either property values or nested Hash objects.

##### Property names

Property names can be objects of any class and their meaning is up to the user. Most often, they would be String or Symbol instances with content that is some formatting-related property name, like `:background_color`.

##### Property values

The values can also be any objects, except for Hash objects, which are interpreted as nested style sheet definitions.

##### Selectors

A selector is a String or Symbol object that contains one or more custom **tag names**, **ids** and **class names**. For example: `#content message.success`.

##### A style sheet example

```ruby
  style_sheet = {
    foreground_color: :white,
    background_color: :blue,

    "#content message.success" => {
      background_color: :green,

      "number" => {
        foreground_color: :inherit
      }
    }
  }
```

### 2. Creating a style sheet handler instance

Then the style sheet should be passed to the handler:

```ruby
  style_sheet_handler = SimpleStyleSheet::Handler.new(style_sheet)
```

### 3. Tag objects

Tag objects represent tags in a HTML-like structure. As a tag, any object can be used, provided that it responds to :name, :id, :class_names and :parent messages. For example:

```ruby
  Tag = Struct.new(:name, :id, :class_names, :parent)

  # Tag objects corresponding to the structure:
  # <section id="content"><message class="success"><number>...</number></message></section>
  content_tag = Tag.new("section", "content", []         , nil)
  message_tag = Tag.new("message", nil      , ["success"], content_tag)
   number_tag = Tag.new("number" , nil      , []         , message_tag)
```

### 4. Getting property value for a given tag

Now, a property value for a given tag can be obtained:

```ruby
  style_sheet_handler.value_for(message_tag, :foreground_color)
   => :white
   
  style_sheet_handler.value_for(message_tag, :background_color)
   => :green

  style_sheet_handler.value_for( number_tag, :foreground_color)
   => :inherit
```

The `#value_for` method looks in the style sheet for selectors that match the given tag. If more than one matching selector is found, the one with highest specificity is used (more details below). Then it returns the value it points to for given property name.

### 5. Getting top-level property value

The `#value_for` method, when called without the tag argument, returns top-level property value (defined in the style sheet without a selector), which may be interpreted as a default one or as a value for text not included in any tags. For example:

```ruby
  style_sheet_handler.value_for(:background_color)
   => :blue
```

Selector specificity
--------------------

Selector specificity information can be found in the description of [simple_selector](http://github.com/jacekmikrut/simple_selector) Ruby gem.

Property name translator (optional)
-----------------------------------

A property name translator allows using multiple names (aliases) for a single property name. For example, property named `:background_color` can have aliases `:background`, `:bg_color` etc.

The translator, that is supposed to be provided by the gem user, should respond to `:translate` method and return the translation for given property name, for example:

```ruby
  property_name_translator.translate(:bg_color)
   => :background_color
```

In order to use the translator, it should be passed as the second argument to SimpleStyleSheet::Handler.new method:

```ruby
  style_sheet_handler = SimpleStyleSheet::Handler.new(style_sheet, property_name_translator)
```

Installation
------------

As a Ruby gem, simple_style_sheet can be installed either by running

```bash
  gem install simple_style_sheet
```

or adding

```ruby
  gem "simple_style_sheet"
```

to the Gemfile and then invoking `bundle install`.

License
-------

License is included in the LICENSE file.
