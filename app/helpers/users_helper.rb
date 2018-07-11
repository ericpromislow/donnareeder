module UsersHelper
  def item_num(paginated_thing, index)
    (paginated_thing.current_page.to_i - 1) * (paginated_thing.per_page) + index
  end
end
