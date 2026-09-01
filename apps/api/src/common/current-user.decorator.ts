import { createParamDecorator, ExecutionContext } from '@nestjs/common';

export type RequestUser = {
  id: string;
};

export const CurrentUser = createParamDecorator((_: unknown, context: ExecutionContext): RequestUser => {
  const request = context.switchToHttp().getRequest<{ user?: RequestUser; headers: Record<string, string | string[] | undefined> }>();
  const headerUserId = request.headers['x-user-id'];
  const id = Array.isArray(headerUserId) ? headerUserId[0] : headerUserId;

  return request.user ?? { id: id || process.env.DEMO_USER_ID || 'demo-user' };
});
