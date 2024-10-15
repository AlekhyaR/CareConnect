# frozen_string_literal: true

class InboxesController < ApplicationController
  def show
    @inbox = Inbox.find_by(user_id: params[:id])
    @messages = Message.select(:id, :body, :outbox_id, :created_at, :read, :replied)
                       .includes(:outbox)
                       .where(inbox: @inbox)
                       .order(created_at: :desc)
                       .page(params[:page])
                       .per(50)
  end
end
