class CreateAgendamentoCalculoContabilizacaoReceitas < ActiveRecord::Migration
  def self.up
    create_table :agendamento_calculo_contabilizacao_receitas do |t|
      t.column :mes,                       :integer
      t.column :ano,                       :integer
      t.column :historico,                 :text
      t.column :usuario_id,                :integer
      t.column :unidade_id,                :integer
      t.column :resultado,                 :string
      t.column :status,                    :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :agendamento_calculo_contabilizacao_receitas
  end
end
