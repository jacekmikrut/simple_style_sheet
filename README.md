SimpleStyleSheet
================

SimpleStyleSheet is a Ruby gem that **parses a CSS-like Hash style sheet** and then **allows searching for property values of given HTML-like tags**. Tag and property names, as well as their meaning, are up to the gem user.

Usage and details
-----------------

### 1. Style sheet preparation

The style sheet is just a CSS-like Hash object. Its keys are either property names or selectors, and values are either property values or nested Hash objects.

##### Property names

Property names can be objects of any class and their meaning is up to the user. Most often, they would be String or Symbol instances with content that is some formatting-related property name, like "background-color".

##### Property values

The values can also be any objects, except for Hash objects, which are interpreted as nested style sheet definitions.

##### Selectors

A selector is a String object that contains one or more custom **tag names**, **ids** and **class names**. For example: `#content message.success`.

##### A style sheet example

```ruby
  style_sheet = {
    "foreground-color" => :white,
    "background-color" => :blue,

    "#content message.success" => {
      "background-color" => :green,

      "number" => {
        "background-color" => :inherit
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
  # <section id="content"><message class="success">...</message></section>
  content_tag = Tag.new("section", "content", [], nil)
  message_tag = Tag.new("message", nil, ["success"], content_tag)
```

### 4. Getting property value for a given tag

Now, a property value for a given tag can be obtained:

```ruby
  style_sheet_handler.value_for(message_tag, "background-color")
   => :green

  style_sheet_handler.value_for(message_tag, "foreground-color")
   => :white
```

The #value_for method looks in the style sheet for selectors that match a given tag. If more than one matching selector is found, the one with highest specificity is used (more details below). Then the value it points to for given property name is returned.

Selector specificity
--------------------

In order to return a property value for a given tag, search for the matching selector of highest specificity is performed.

The specificity of each selector is calculated according to rules similar to the standard CSS rules.

The specificity is four numbers: **a,b,c,d**.

**The rules respected by this gem are**:

* **a** is always 0;
* **b** is the number of ID attributes in the selector;
* **c** is the number of class names in the selector;
* **d** is the number of tag names in the selector.

For example, a selector `tag#id1.class1 #id2.class2.class3` has specificity equal to `0,2,3,1`.

Two selector specificities are compared by succesively comparing their corresponding numbers, from left to right.

Property name translator
------------------------

A property name translator allows using multiple names (or aliases) for a single property name. For example, property named "background-color" can have aliases "background", "bg-color" etc.

The translator, that is supposed to be provided by the gem user, should respond to :translate method and return the translation for a given property name, for example:

```ruby
  property_name_translator.translate("bg-color")
   => "background-color"
```

In order to use the translator, it should be passed as the second argument to SimpleStyleSheet::Handler.new method:

```ruby
  style_sheet_handler = SimpleStyleSheet::Handler.new(style_sheet, property_name_translator)
```

Installation
------------

As a Ruby gem, SimpleStyleSheet can be installed either by running

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
