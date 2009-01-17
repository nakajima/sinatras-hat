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


(c) Copyright 2008-2009 Pat Nakajima. All Rights Reserved. 