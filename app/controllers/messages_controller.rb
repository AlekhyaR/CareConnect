# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_message, only: [:show]

  def show
    @message.mark_as_read if @message.unread?
    return unless @message.nil?

    render plain: 'Not Found', status: :not_found
  end

  def new
    @message = Message.new
    @users = User.all
  end

  def create
    @users = User.all
    # Distinguish between new message and reply
    @message = if params[:message][:reply_to_id].present?
                 Message.create_reply(message_params)
               else
                 # New message
                 Message.create_message(message_params)
               end

    if @message.persisted?
      redirect_to root_path, notice: I18n.t('messages.create.success_notice')
    else
      flash.now[:alert] = I18n.t('messages.create.error_notice', message: @message.errors.full_messages.join(', '))
      render :new
    end
  end

  def index
    @messages = [Message.first]
  end

  private

  def set_message
    @message = Message.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body, :reply_to_id, :inbox_id, :outbox_id)
  end
end
