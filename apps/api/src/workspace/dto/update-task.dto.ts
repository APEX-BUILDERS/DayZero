import { IsDateString, IsIn, IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class UpdateTaskDto {
  @IsOptional()
  @IsString()
  @MaxLength(160)
  title?: string;

  @IsOptional()
  @IsDateString()
  deadline?: string;

  @IsOptional()
  @IsDateString()
  scheduleDate?: string;

  @IsOptional()
  @IsIn(['high', 'medium', 'low'])
  priority?: 'high' | 'medium' | 'low';

  @IsOptional()
  @IsIn(['pending', 'done', 'missed', 'rescheduled'])
  status?: 'pending' | 'done' | 'missed' | 'rescheduled';

  @IsOptional()
  @IsInt()
  @Min(5)
  estimatedMinutes?: number;
}
