class ItemsController < ApplicationController
  require 'payjp'
  before_action :set_item, only: [:show, :edit, :update, :purchase, :buy]
  before_action :set_card, only: [:purchase, :buy]
  before_action :user_redirect, only: [:edit, :update]
  def index
    if Rails.env == "test" then
      category1 = 1
      category2 = 200
      category3 = 680
      category4 = 893
    else
      categories = [1, 200, 680, 893, 1088]
      recommenndCategories = categories.sample(4)

      category1 = recommenndCategories[0]
      category2 = recommenndCategories[1]
      category3 = recommenndCategories[2]
      category4 = recommenndCategories[3]

    end

    @itemsCategory1 = Item.where(category_id: [Category.find(category1).descendant_ids]).order('id Desc').limit(10)
    @CategoryName1 = Category.find(category1).name
    @itemsCategory2 = Item.where(category_id: [Category.find(category2).descendant_ids]).order('id Desc').limit(10)
    @CategoryName2 = Category.find(category2).name
    @itemsCategory3 = Item.where(category_id: [Category.find(category3).descendant_ids]).order('id Desc').limit(10)
    @CategoryName3 = Category.find(category3).name
    @itemsCategory4 = Item.where(category_id: [Category.find(category4).descendant_ids]).order('id Desc').limit(10)
    @CategoryName4 = Category.find(category4).name

  end

  def new
    @item = Item.new
    10.times {@item.images.build}
  end

  def create
    @item = Item.new(item_params)
    if @item.save
      redirect_to root_path
    else
      10.times {@item.images.build}
      render :new
    end
  end

  def show
  end

  def edit
      @item.images.each do |image|
        image.name.cache!
      end
      (10 - @item.images.count).times {@item.images.build}
  end

  def update


    if @item.update(item_params)
      redirect_to item_path(params[:id])
    else
      (10 - @item.images.count).times {@item.images.build}
      render :edit
    end
  end

  def destroy
  end

  def purchase
    if @card
      Payjp.api_key = Rails.application.credentials.PAYJP_PRIVATE_KEY
      customer = Payjp::Customer.retrieve(@card.customer_id)
      @default_card_information = customer.cards.retrieve(@card.card_id)
    end
  end
  
  def buy
    if @card.blank?
      redirect_to new_card_path
    else
      Payjp.api_key = Rails.application.credentials.PAYJP_PRIVATE_KEY
      Payjp::Charge.create(
      amount: @item.price,
      customer: @card.customer_id,
      currency: 'jpy',
      )
      if @item.update(status: 1, buyer_id: current_user.id)
        redirect_to item_path(params[:id])
      else
        redirect_to item_path(params[:id])
      end
    end
  end
  private



  def set_item
    @item = Item.find(params[:id])
  end

  def user_redirect
    unless user_signed_in?
      redirect_to root_path
    else
      redirect_to root_path unless current_user.id == @item.user.id  
    end
  end

  def item_params
    params.require(:item).permit(
      :name, 
      :text, 
      :size_id, 
      :category_id, 
      :damage, 
      :postage_side, 
      :prefecture_id, 
      :delivery_method, 
      :arrival, 
      :price, 
      images_attributes: [
        :id,
        :name,
        :name_cache
      ]
    ).merge(user_id: current_user.id)
  end
    
  def set_card
    @card = current_user.card
  end

end
