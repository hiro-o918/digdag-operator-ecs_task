package pro.civitaspo.digdag.plugin.ecs_task.run
import io.digdag.client.config.Config
import io.digdag.spi.{OperatorContext, TaskResult, TemplateEngine}
import pro.civitaspo.digdag.plugin.ecs_task.AbstractEcsTaskOperator

class EcsTaskRunOperator(operatorName: String, context: OperatorContext, systemConfig: Config, templateEngine: TemplateEngine)
    extends AbstractEcsTaskOperator(operatorName, context, systemConfig, templateEngine) {

  override def runTask(): TaskResult = {
    null
  }
}
