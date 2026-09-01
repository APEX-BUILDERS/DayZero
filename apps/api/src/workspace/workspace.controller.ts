import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { CurrentUser, RequestUser } from '../common/current-user.decorator';
import { GenerateWorkspaceDto } from './dto/generate-workspace.dto';
import { WorkspaceService } from './workspace.service';

@Controller('workspace')
export class WorkspaceController {
  constructor(private readonly workspaceService: WorkspaceService) {}

  @Post('generate')
  generate(@CurrentUser() user: RequestUser, @Body() dto: GenerateWorkspaceDto) {
    return this.workspaceService.generate(user.id, dto.prompt);
  }

  @Get(':id')
  findOne(@CurrentUser() user: RequestUser, @Param('id') id: string) {
    return this.workspaceService.findOne(user.id, id);
  }
}
