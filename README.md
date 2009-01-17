# Sinatra's Hat

Easy REST-ful apps with Sinatra.

Using Sinatra's Hat is centered around the `mount` method, which is
added to `Sinatra::Base`. It takes at bare minimum a model class. This
class will be mounted as a REST-ful resource, giving you all the CRUD
actions, as well as `new` and `edit` actions. Let's look at some code:

<pre>
mount Article
</pre>

Now you've basically got the same functionality as you'll get in Rails
by running `script/generate scaffold Article`. The views for your `Article`
will live in `views/articles`, and be named `index.erb`, `show.erb`, etc.

You can look at my [Hatter](http://github.com/nakajima/hatter/tree/master)
project, or the `examples/` directory in this one to see this in action.

Go ahead, try it.

## ORM agnostic? Or ORM atheist?

By default, Sinatra's Hat works with ActiveRecord. That means that going
to `/articles` will simply call `Article.all` to populate the `@articles`
instance variable. Going to `/articles/2` will call `Article.find_by_id(2)`
to populate the `@article` instance variable.

We call `find_by_id` instead of `find` because the `record` option should
simply return `nil` when the record can't be found.

Not every class is an ActiveRecord though (especially if you're not using
ActiveRecord). That's why you can use the `finder` and `record` options.

This example will show you how to use DataMapper with Sinatra's Hat:

<pre>
mount Article do
  finder { |model, params| model.all }
  record { |model, params| model.first(:id => params[:id]) }
end
</pre>

As you can see, both `finder` and `record` take a block, which will get
passed the "model" and `params` for each request. The reason you should use
the "model" argument instead of referencing the class directly is that
when you start nesting mounted models, then Sinatra's Hat will attempt to
pass the association proxy as the model argument instead of the class itself.

"Nested mounted models?" you ask?

## Nested mounted models.

You don't want to have to expose your entire application at the top level
of URL paths. That wouldn't be very RESTful, and more importantly, it'd be
damn ugly. So Sinatra's Hat allows you to nest resources:

<pre>
mount Article do
  mount Comment
end
</pre>

With this example, you'd get `/articles/1/comments`, `/articles/1/comments/1`
and all the rest of the actions you get for articles, just nested. As long
as your `Article` model supports a `comments` association proxy, then the `finder`
and `record` options for `Comment` will automatically scope their results by
the parent `Article`.

## `.xml`, `.json`, `.yaml`, and whatever else you want

If a request has a format extensions, then Sinatra's Hat will first check
to see if it has a custom way of serializing that format. To specify a 
custom formatter, you can use the `formats` hash:

<pre>
mount Article do
  formats[:ruby] = { |data| data.inspect }
end
</pre>

With that custom formatter, a request to `/articles.ruby` will return
the equivalent of `Article.all.inspect`.

### Automatic formatters

If you don't specify a custom formatter, then Sinatra's Hat will try to
call `to_#{format}` on the record object. That means that with most ORMs,
things like `to_xml`, `to_json`, and `to_yaml` will be supported right out
of the box.

## Default Flows

Sinatra's Hat has some default flows:

### After the `create` action

**On Success**: If a record is successfully created, Sinatra's Hat will redirect to that
record's show page.

**On Failure**: If a record cannot be saved, Sinatra's Hat will render the `new` action.

### After the `Update` action

**On Success**: If a record is successfully updated, Sinatra's Hat will redirect to that
record's show page.

**On Failure**: If a record cannot be updated, Sinatra's Hat will render the `edit` action.

## Custom Flows

To specify custom flows for your actions, you can use the `after` method.

Let's say that after a user creates an Article, you want to render the
article's edit action, and if it can't be created, you want to redirect
back to the articles index.

<pre>
mount Article do
  after :create do |on|
    on.success { |record| render(:edit) }
    on.failure { |record| redirect(:index) }
  end
end
</pre>

### `redirect` options

When specifying a custom redirect, you can pass one of a few things:

#### A String

When you pass `redirect` a string, the redirect will go to that string.

<pre>
after :create do |on|
  on.success { |record| redirect("/articles/#{record.to_param}") }
end
</pre>

#### A Record

When you pass `redirect` a record, the redirect will go to the show
action for that record.

<pre>
after :create do |on|
  on.success { |record| redirect(record) }
end
</pre>

#### A symbol

If you pass `redirect` the name of an action as a symbol (like `:index`),
then the redirect will go to the correct path for that option:

<pre>
after :create do |on|
  on.success { redirect(:index) }
end
</pre>

When the action requires a record (like `:show`), then just pass the
record as a second argument:

<pre>
after :create do |on|
  on.success { |record| redirect(:show, record) }
end
</pre>

### Responding with a `render`

When you want your response to just render a template, just call `render`
with the name of the template:

<pre>
after :create do |on|
  on.failure { |record| render(:new) }
end
</pre>

## Other Stuff

I'll be writing docs for the following topics soon:

* Specifying which actions to generate
* Protecting actions with basic auth

(c) Copyright 2008-2009 Pat Nakajima. All Rights Reserved. 